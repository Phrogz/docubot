# encoding: UTF-8

# The index links keywords to a particular page.
#
# Keywords are added to the index by:
#  * Having a "keywords" entry in the metasection, e.g.
#    keywords: Rigid Bodies, Dynamic, Physical Mesh
#  * Surrounding a word or phrase on the page with two @ characters, e.g.
#    The purpose of a @@physical mesh@@ is to...
#  * Having an "index: headings" entry in the metasection, causing each
#    heading on the page to be added to the index.
#  * Having an "index: definitions" entry in the metasection, causing each
#    <dt>...</dt> on the page to be added to the index.
#    (May be combined with the above as "index: headings definitions".)
#
# As shown above, terms may be referenced in title or lowercase.
# Names with capital letters will be favored over lowercase in the index.
class DocuBot::Index
	attr_reader :entries
	def initialize( bundle )
		@bundle    = bundle
		@entries   = Hash.new{|h,k|h[k]=[]} # key points to array of DocuBot::Pages
		@downcased = {}
		#TODO: support links to sub-sections instead of just pages
	end
	
	# Run through the 'keywords' and 'index' meta attribute for a page and add entries
	# Note: in-content @@keyword@@ marks are processed by snippets/index_entries.rb 
	def process_page( page )
		page.keywords.split(/,\s*/).each{ |key| add( key, page ) } if page.keywords?

		html = page.to_html
		unless page['no-index'] && page['no-index'].include?( 'headings' )
			#TODO: Fix the regex to use a backreference to ensure the correct closing tag, once 1.8x support is not necessary
			html.scan( %r{<h[1-6][^>]*>(.+?)</h[1-6]>}im ){ |captures| add( captures.first, page ) }
		end

		unless page['no-index'] && page['no-index'].include?( 'definitions' )
			html.scan( %r{<dt[^>]*>(.+?)</dt>}im ){ |captures| add captures.first, page }
		end
	end
	
	def add( term, page )
		term.strip!
		term.gsub!(/<[^>]+>/,'')
		down = term.downcase
		if existing = @downcased[ down ]
			# The existing entry might be early-arriving all-lowercase.
			# If the new term has more capital letters, it wins.
			if term.scan(/[A-Z]/).length > existing.scan(/[A-Z]/).length
				@downcased[ down ] = term
				@entries[ term ] = @entries[ existing ]
				@entries.delete( existing )
			else
				term = existing
			end
		end
		@entries[ term ] << page
		@entries[ term ].uniq!
		@downcased[ down ] = term
	end
	
	def each
		@entries.each{ |term, pages| yield term, pages }
	end
end

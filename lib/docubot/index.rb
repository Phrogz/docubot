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
		if page.index? && page.index.downcase=='headings'
			#TODO: Do we need/want a proper HTML parser rather than regex?
			#FIXME: Really, call to_html here?
			#TODO: Fix the regex to use a backreference to ensure the correct closing tag, once 1.8x support is not necessary
			page.to_html.scan( %r{<h[1-6][^>]*>(.+?)</h[1-6]>}im ) do |captures|
				add( captures.first, page )
			end
		end
	end
	
	def add( term, page )
		term.strip!
		down = term.downcase
		if existing = @downcased[ down ]
			# The existing entry might be early-arriving all-lowercase.
			# If the new term has more capital letters, it wins.
			if term.scan(/[A-Z]/).length > existing.scan(/[A-Z]/).length
				@downcased[ down ] = term
			else
				term = existing
			end
		end
		@entries[ term ] << page
		@entries[ term ].uniq!
		@downcased[ down ] = term
	end
end

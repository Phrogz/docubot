# encoding: UTF-8
class DocuBot::Glossary
	attr_accessor :bundle, :entries
	def initialize( bundle, dir )
		@entries   = {}
		@downcased = {}
		@bundle    = bundle
		@missing   = Hash.new{ |h,k| h[k]=[] }
		# .directory? also ensures that the path exists
		if File.directory?( dir )
			@directory = File.expand_path( dir )
			# Dir[ dir/'*' ].each do |item|
			# 	page = DocuBot::Page.new( @bundle, item )
			# 	self << page
			# end
		end
	end
	def []=( term, definition )
		@entries[ term ] = definition
		@downcased[ term.downcase ] = term
		@missing.delete( term.downcase )
	end
	def []( term )
		@entries[ @downcased[ term.downcase ] ]
	end
	def term_used( term, referring_page )
		down = term.downcase
		unless @downcased[down]
			@missing[down] << referring_page
			@missing[down].uniq!
		end
	end
	def each
		@entries.each{ |term,page| yield term, page }
	end
	def missing_terms
		@missing
	end
	def <<( page )
		self[ page.title ] = page
	end
	def to_js
		"$glossaryTerms = {#{
			@entries.reject{ |term,page| page.hide }.map do |term,page|
				"'#{term.downcase.gsub("'","\\\\'")}':'#{page.to_html.gsub("'","\\\\'").gsub(/[\r\n]/,'\\n')}'"
			end.join(",\n")
		}};"
	end
end
# encoding: UTF-8
class DocuBot::Glossary
	attr_accessor :bundle, :entries
	def initialize( bundle, dir )
		@entries   = {}
		@downcased = {}
		@bundle    = bundle
		@missing   = []
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
	end
	def []( term )
		@entries[ @downcased[ term.downcase ] ]
	end
	def each
		@entries.each{ |term,page| yield term, page }
	end
	def add_missing_term( term )
	  @missing << term.downcase
		# File.open( @directory/"#{term}.md", "w" ){ |f| f << "<span class='todo'>TODO: define #{term}</span>" } if @directory
	end
	def missing_terms
		# Terms may have been defined after being first seen
		@missing.reject{ |term| self[term] }.uniq
	end
	def <<( page )
		self[ page.title ] = page
	end
	def to_js
		"$glossaryTerms = {#{@entries.map{ |term,page| "'#{term.downcase.gsub("'","\\\\'")}':'#{page.to_html.gsub("'","\\\\'").gsub(/[\r\n]/,'\\n')}'" }.join(",\n")}};"
	end
end
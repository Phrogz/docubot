# encoding: UTF-8
class DocuBot::Glossary
	attr_accessor :bundle
	def initialize( bundle, dir )
		@entries   = {}
		@downcased = {}
		@bundle    = bundle
		@missing   = []
		# .directory? also ensures that the path exists
		if File.directory?( dir )
			@directory = File.expand_path( dir )
			# Dir[ dir/'*' ].each do |item|
			# 	page = DocuBot::Page.new( item )
			# 	page.bundle = @bundle
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
		@entries.each{ |term,defn| yield term, defn }
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
		#TODO: perhaps don't serialize the page here, but wait until some #write call gives us a template so we can use that?
		self[ page.title ] = page.to_html
	end
	def to_js
		"$glossaryTerms = {#{@entries.map{ |term,defn| "'#{term.downcase.gsub("'","\\\\'")}':'#{defn.gsub("'","\\\\'").gsub(/[\r\n]/,'\\n')}'" }.join(",\n")}};"
	end
end
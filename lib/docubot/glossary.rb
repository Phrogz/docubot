class DocuBot::Glossary
	attr_accessor :bundle
	def initialize
		@entries   = {}
		@downcased = {}
	end
	def []=( term, definition )
		@entries[ term ] = definition
		@downcased[ term.downcase ] = term
	end
	def []( term )
		@entries[ @downcased[ term.downcase ] ]
	end
	def each
		@entries.each{ |term,def| yield term, def }
	end
	def to_html( template_dir )
		template = Haml::Engine.new( IO.read_utf8( template_dir / 'glossary.haml' ), DocuBot::Bundle::HAML_OPTIONS )
		template.render( Object.new, :glossary=>self )
	end
end
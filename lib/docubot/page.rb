require 'yaml'
class DocuBot::Page
	META_SEPARATOR = /^\+\+\+$/ # Sort of like +++ATH0

	attr_reader :html

	def self.from_file( filename, title=nil, type=:md )
		title ||= DocuBot.name( filename )
		type  ||= File.extname( filename )[ 1..-1 ]
		new( File.read(filename), title, type )
	end

	def initialize( source, title=nil, type=:md )
		parts = source.split( META_SEPARATOR, 2 )
		@meta = { 'title'=>title }
		@meta.merge!( YAML.load( parts.first ) ) if parts.length > 1
		@html = DocuBot::convert_to_html( parts.last, type )
		@html = DocuBot::process_snippets( @html )
	end

	def method_missing( method, *args )
		key=method.to_s
		case key[-1..-1]
			when '?' then @meta.has_key?( key[0..-2] )
			when '!', '=' then super
			else @meta[ key ]
		end
	end
	
	def to_s( depth=0 )
		"#{'  '*depth}#{@meta['title']}"
	end
end

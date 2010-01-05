require 'rubygems'
require 'yaml'
require 'bluecloth'

module CHMBot; end

module CHMBot::Converter
	@@converter_by_type = {}
	def converts_for( *types )
		types.each{ |type| @@converter_by_type[type.to_s] = self }
	end
	def self.convert_to_html( source, type )
		converter = @@converter_by_type[type.to_s]
		raise "No #{self.class} found for type #{type}" unless converter
		converter.new( source ).to_html
	end
end

class BlueCloth
	extend CHMBot::Converter
	converts_for :md, :markdown
end

class CHMBot::Page
	META_SEPARATOR = /^\+\+\+$/ # Sort of like +++ATH0

	attr_reader :html

	def self.from_file( filename, title=nil, type=:md )
		title ||= File.basename( filename ).sub( /\.[^.]+$/, '' ).gsub( '_', ' ' ).sub( /^\d*\s/, '' )
		type  ||= File.extname( filename )[ 1..-1 ]
		new( File.read(filename), title, type )
	end
	
	def initialize( source, title=nil, type=:md )
		parts = source.split( META_SEPARATOR, 2 )
		@meta = { 'title'=>title }
		@meta.merge!( YAML.load( parts.first ) ) if parts.length > 1
		@html = CHMBot::Converter.convert_to_html( parts.last, type )
	end
	
	def method_missing( method, *args )
		key=method.to_s
		case key[-1..-1]
			when '?' then @meta.has_key?( key[0..-2] )
			when '!', '=' then super
			else @meta[ key ]
		end
	end
end

# I'm too lazy to enter the syntax for directory with spaces
# So just find the 3_more_crap.md file that has metadata.
file = Dir['**/**'].grep( /3/ ).first
x = CHMBot::Page.from_file( file )
p x.title?, x.title, x.foo?, x.foo
require 'rubygems'
require 'haml'
class Hamlizer < Haml::Engine
	extend DocuBot::Converter
	converts_for :haml
	def initialize( source )
		super( source, :format=>:html4, :ugly=>true )
	end
	alias_method :to_html, :render
end

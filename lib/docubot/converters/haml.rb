require 'rubygems'
require 'haml'
class DocuBot::Hamlizer < Haml::Engine
	extend DocuBot::Converter
	converts_for :haml
	def initialize( source )
		super( source, :format=>:html4, :ugly=>true )
	end
	def to_html( template_dir )
		render
	end
end

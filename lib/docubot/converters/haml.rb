# encoding: UTF-8
require 'rubygems'
require 'haml'
options = { :format=>:html4, :ugly=>true }
options.merge!( :encoding=>'utf-8' ) if Object.const_defined? "Encoding"

DocuBot::Converter.to_convert :haml do |page, source|
	Haml::Engine.new( source, options ).render( page, :page=>page, :global=>page.bundle.global, :root=>page.root )
end

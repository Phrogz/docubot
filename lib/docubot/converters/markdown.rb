# encoding: UTF-8
require 'rubygems'
begin
	require 'bluecloth'
	DocuBot::Converter.to_convert :md, :markdown do |page, source|
		# BlueCloth 2.0.5 takes UTF-8 source and returns ASCII-8BIT
		result = BlueCloth.new(source).to_html
		result.encode!( 'UTF-8', :undef=>:replace ) if Object.const_defined? "Encoding"
		result		
	end
rescue LoadError
	warn "Unable to load bluecloth gem; *.markdown/*.md markup will not be recognized as a page."
end


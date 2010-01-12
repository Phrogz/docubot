# encoding: UTF-8
require 'rubygems'
begin
	require 'bluecloth'
	class BlueCloth
		extend DocuBot::Converter
		converts_for :md, :markdown
		alias_method :bc_to_html, :to_html
		def to_html
			# BlueCloth 2.0.5 takes UTF-8 source and returns ASCII-8BIT
			result = bc_to_html
			result.encode!( 'UTF-8', :undef=>:replace ) if Object.const_defined? "Encoding"
			result
		end
	end
rescue LoadError
	warn "Unable to load bluecloth gem; *.markdown/*.md markup will not be recognized as a page."
end


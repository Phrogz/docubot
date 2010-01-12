# encoding: UTF-8
require 'rubygems'
begin
	require 'redcloth'
	module RedCloth
		extend DocuBot::Converter
		converts_for :textile, :rc
	
		class << self
			alias_method :rc_new, :new
			def new( markup )
				rc_new( markup, [:no_span_caps] )
			end
		end
	end
rescue LoadError
	warn "Unable to load RedCloth gem; textile markup will not be recognized as a page."
end

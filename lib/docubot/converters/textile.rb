# encoding: UTF-8
require 'rubygems'
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

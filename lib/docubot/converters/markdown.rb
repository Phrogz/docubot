# encoding: UTF-8
require 'rubygems'
require 'bluecloth'
class BlueCloth
	extend DocuBot::Converter
	converts_for :md, :markdown
	alias_method :bc_to_html, :to_html
	def to_html
		# BlueCloth 2.0.5 takes UTF-8 source and returns ASCII-8BIT
		bc_to_html.encode( 'UTF-8', :undef=>:replace )
	end
end

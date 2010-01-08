# encoding: UTF-8
require 'rubygems'
require 'bluecloth'
class BlueCloth
	extend DocuBot::Converter
	converts_for :md, :markdown
end

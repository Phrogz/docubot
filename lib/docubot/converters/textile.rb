# encoding: UTF-8
require 'rubygems'
require 'redcloth'
module RedCloth
	extend DocuBot::Converter
	converts_for :textile, :rc
end

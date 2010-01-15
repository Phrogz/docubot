# encoding: UTF-8
require 'cgi'
class DocuBot::CodeConverter
	extend DocuBot::Converter
	converts_for :rb, :c, :h, :cpp, :cs, :txt, :raw
	def initialize( text )
		@text = text
	end
	def to_html
		@html ||= "<pre>#{CGI.escapeHTML @text}</pre>"
	end
end

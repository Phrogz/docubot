# encoding: UTF-8
class DocuBot::HTMLPassthrough
	extend DocuBot::Converter
	converts_for :html, :htm
	def initialize( html )
		# TODO: If the html is inside a body, strip out the surrounds.
		@html = html
	end
	def to_html
		@html
	end
end

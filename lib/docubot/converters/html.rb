class DocuBot::HTMLPassthrough
	extend DocuBot::Converter
	converts_for :html, :htm
	def initialize( html )
		@html = html
	end
	def to_html
		@html
	end
end

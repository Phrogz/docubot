# encoding: UTF-8
DocuBot::Converter.to_convert :html, :htm do |page, source_html|
	# TODO: If the html is inside a body, strip out the surrounds.
	source_html
end

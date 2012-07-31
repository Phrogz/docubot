# encoding: UTF-8
begin
	require 'redcloth'
	DocuBot::Converter.to_convert :textile, :rc do |page, source|
		RedCloth.new(source,[:no_span_caps]).to_html
	end
rescue LoadError
	warn "Unable to load RedCloth gem; *.textile/*.rc markup will not be recognized as a page."
	warn "(Use   gem install RedCloth  to fix this, if you need Textile processing.)"
end

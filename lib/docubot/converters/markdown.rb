# encoding: UTF-8
begin
	require 'kramdown'
	DocuBot::Converter.to_convert :md, :markdown do |page, source|
		Kramdown::Document.new(source,coderay_line_numbers:nil, coderay_css: :class).to_html
	end
rescue LoadError
	warn "Unable to load kramdown gem; *.markdown/*.md markup will not be recognized as a page."
	warn "(Use   gem install kramdown  to fix this, if you need Markdown processing.)"
end


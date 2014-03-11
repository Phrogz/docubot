# encoding: UTF-8
begin
	require 'kramdown'
	DocuBot::Converter.to_convert :md, :markdown do |page, source|
		options = page.meta.highlight=='off' ? {enable_coderay:false} : {coderay_line_numbers:nil, coderay_css: :class}
		Kramdown::Document.new(source,options).to_html
	end
rescue LoadError
	warn "Unable to load kramdown gem; *.markdown/*.md markup will not be recognized as a page."
	warn "(Use   gem install kramdown  to fix this, if you need Markdown processing.)"
end


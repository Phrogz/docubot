# encoding: UTF-8
begin
	require 'kramdown'
	DocuBot::Converter.to_convert :md, :markdown do |page, source|
		Kramdown::Document.new(source).to_html.tap do |result|
			# BlueCloth 2.0.5 takes UTF-8 source and returns ASCII-8BIT
			# result.encode!( 'UTF-8', :undef=>:replace ) if Object.const_defined? "Encoding"
		end
	end
rescue LoadError
	warn "Unable to load kramdown gem; *.markdown/*.md markup will not be recognized as a page."
	warn "(Use   gem install kramdown  to fix this, if you need Markdown processing.)"
end


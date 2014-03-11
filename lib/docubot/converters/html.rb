# encoding: UTF-8
begin
	require 'coderay'
rescue LoadError
	warn "Unable to load coderay gem; code blocks will not support syntax highlighting."
	warn "(Use   gem install coderay   to fix this, if you desire syntax highlighting.)"
end

DocuBot::Converter.to_convert :html, :htm do |page, source_html|
	body = Nokogiri.HTML( source_html ).at('body')
	if page.meta.highlight!='off' && defined? CodeRay 
		@coderay_languages ||= {}.tap do |h|
			# Valid as of CodeRay 1.1
			langs = h[:all] = %w[cpp cplusplus ecmascript java_script ecma_script rhtml erb eruby irb ruby javascript js pascal delphi patch diff plain text plaintext xhtml html yml yaml default c css clojure debug java groovy haml json php python raydebug sql xml]
			h[:regex] = /(?<=\A|\s)language-(#{Regexp.union(langs)})(?=\s|\z)/
			h[:css]   = langs.map{ |l| ".language-#{l}" }.join(',')
		end
		body.css(@coderay_languages[:css]).each do |possible|
			if lang=possible['class'][@coderay_languages[:regex],1]
				possible.inner_html = CodeRay.scan( possible.text, lang.to_sym ).html
			end
		end
	end
	body.inner_html
end

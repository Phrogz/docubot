# encoding: UTF-8
require 'cgi'
DocuBot::Converter.to_convert :rb, :c, :h, :cpp, :cs, :txt, :raw do |page, source|
	"<pre>#{CGI.escapeHTML source}</pre>"
end

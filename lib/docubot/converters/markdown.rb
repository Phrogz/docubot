require 'rubygems'
require 'bluecloth'
class BlueCloth
	extend DocuBot::Converter
	converts_for :md, :markdown
end

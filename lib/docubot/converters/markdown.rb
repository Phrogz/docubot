require 'rubygems'
require 'bluecloth'
class DocuBot::Markdowner < BlueCloth
	extend DocuBot::Converter
	converts_for :md, :markdown
	def to_html( template_dir )
		super()
	end
end

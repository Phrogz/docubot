class DocuBot::RubyEvaluator
	extend DocuBot::Converter
	converts_for :rb, :ruby
	def initialize( source )
		@ruby = source
	end
	def to_html( template_dir )
		"<div>#{eval(@ruby)}</div>"
	end
end

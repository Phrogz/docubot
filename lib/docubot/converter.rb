module DocuBot
	module Converter
		@@by_type = {}
		def converts_for( *types )
			types.each{ |type| @@by_type[type.to_s] = self }
		end
		def self.by_type
			@@by_type
		end
	end

	def self.convert_to_html( source, type )
		converter = DocuBot::Converter.by_type[ type.to_s ]
		raise "No converter found for type #{type}" unless converter
		converter.new( source ).to_html
	end
end

Dir[ DocuBot::DIR/'docubot/converters/*.rb' ].each do |converter|
	require converter
end
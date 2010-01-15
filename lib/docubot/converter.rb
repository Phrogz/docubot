# encoding: UTF-8
module DocuBot
	module Converter
		@by_type = {}
		def self.to_convert( *types, &block )
			types.each{ |type| @by_type[type.to_s] = block }
		end
		def self.by_type
			@by_type
		end
	end

	def self.convert_to_html( page, source, type )
		if converter = DocuBot::Converter.by_type[ type.to_s ]
			puts "Converting #{type}: #{source.inspect[0..60]}" if $DEBUG
			converter[ page, source ]
		else
			raise "No converter found for type #{type}"
		end
	end
end

Dir[ DocuBot::DIR/'docubot/converters/*.rb' ].each do |converter|
	require converter
end
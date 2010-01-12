# encoding: UTF-8
module DocuBot
	module Writer
		@@by_type = {}
		def handles_type( *types )
			types.each{ |type| @@by_type[type.to_s] = self }
		end
		def self.by_type
			@@by_type
		end
		DIR = File.expand_path( DocuBot::DIR / 'docubot/writers' )
		Dir.chdir DIR do
			INSTALLED_WRITERS = Dir['*']
		end
	end

	def self.write_bundle( bundle, type, destination  )
		writer = DocuBot::Writer.by_type[ type.to_s ]
		raise "No writer found for type #{type}" unless writer
		writer.new( bundle ).write( destination )
	end
end

Dir[ DocuBot::Writer::DIR/'*.rb' ].each do |writer|
	require writer
end
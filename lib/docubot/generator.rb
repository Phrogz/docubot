module DocuBot
	GENERATOR_DEFAULTS = {
		:template => 'default'
	}
	def self.generate( directory, options={} )
		options = GENERATOR_DEFAULTS.merge( options )
		
		if !File.exists?( directory )
			raise "DocuBot cannot find directory #{File.expand_path(directory)}. Exiting."
		end
		
		use_template( options[:template] )
		
		@toc = DocuBot::Section.new( 'Table of Contents' )
		sections_by_path = {}
		
		Dir[ File.join( directory, '**/*' ) ].each do |item|
			parent = sections_by_path[ File.dirname( item ) ] || @toc
			if File.directory?( item )
				section = DocuBot::Section.new( DocuBot.name( item ) )
				sections_by_path[ item ] = section
				parent << section
			else
				parent << DocuBot::Page.from_file( item )
			end
		end
		
		puts @toc

		output = "#{directory}_html"
		Dir.mkdir(output) unless File.exists?(output)
		
		# TODO: CHM the results
	end
end
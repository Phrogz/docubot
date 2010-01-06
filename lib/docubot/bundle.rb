class	DocuBot::Bundle
	attr_reader :toc, :extras
	def initialize( source_directory )
		@source = source_directory
		@extras = []
		if !File.exists?( @source )
			raise "DocuBot cannot find directory #{File.expand_path(@source)}. Exiting."
		end
		@toc = DocuBot::Section.new( "Table of Contents" )
		sections_by_path = {}

		Dir[ File.join( @source, '**/*' ) ].each do |item|
			parent = sections_by_path[ File.dirname( item ) ] || @toc
			if File.directory?( item )
				section = DocuBot::Section.new( DocuBot.name( item ) )
				sections_by_path[ item ] = section
				parent << section
			else
				extension = File.extname( item )[ 1..-1 ]
				if DocuBot::Converter.by_type[ extension ]
					parent << DocuBot::Page.from_file( item )
				else
					# TODO: Anything better needed?
					@extras << item
				end
			end
		end
	end
	
	def write( template='default', destination=nil )
		destination ||= File.join( File.dirname(@source), "#{File.basename @source}_html" )

		unless DocuBot::INSTALLED_TEMPLATES.include?( template )
			raise "Cannot write DocuBot Bundle: the specified template '#{template}' does not exist in #{TEMPLATE_DIRECTORY}."
		end

		Dir.mkdir(destination) unless File.exists?(destination)

		# TODO: Write HTML files
		# TODO: Store/copy extras from source
		# TODO: Look in template directory for 'extras' directory and copy contents
		# TODO: CHM
	end

end
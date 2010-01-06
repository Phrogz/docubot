class	DocuBot::Bundle
	attr_reader :toc, :extras
	FALLBACK_PAGE    = "%h1= @title\n#content= @page"
	FALLBACK_SECTION = "- @sections.each do |section|\n\t\#{section.title}: \#{section.summary}"
	HAML_OPTIONS     = { :format=>:html4, :ugly=>true }
	
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
		require 'fileutils'
		
		destination ||= File.join( File.dirname(@source), "#{File.basename @source}_html" )
		Dir.mkdir(destination) unless File.exists?(destination)
				
		template_dir = File.join( DocuBot::TEMPLATE_DIR, template )
		unless File.exists?( template_dir )
			warn "The specified template '#{template}' does not exist in #{DocuBot::TEMPLATE_DIRECTORY}.\nUnwrapped HTML output only."
		end

		extra_files = File.join( template_dir, 'extras' )
		if File.exists?( extra_files )
			FileUtils.copy( Dir[ File.join extra_files, '*' ], destination )
		end
		
		page_template = File.join( template_dir, 'page.haml' )
		page_template = File.exists?( page_template ) ? IO.read( page_template ) : FALLBACK_PAGE
		page_template = Haml::Engine.new( page_template, HAML_OPTIONS )
		Dir.chdir destination do
			@toc.every_page.each do |page|
				#FIXME: Page titles may not be unique. Need to generate unique file names; associated with originals for links to work.
				file = page.title.gsub(/\W+/,'_') + '.html'
				html = page_template.render( Object.new, :page=>page )
				File.open( file, 'w' ){ |f| f << html }
			end
		end
		
		section_template = File.join( template_dir, 'section.haml' )
		section_template = File.exists?( section_template ) ? IO.read( section_template ) : FALLBACK_SECTION
		section_template = Haml::Engine.new( section_template, HAML_OPTIONS )
		Dir.chdir destination do
			@toc.every_section.each_with_index do |section,i|
				file = "_Section_#{i}.html"
				html = section_template.render( Object.new, :section=>section )
				File.open( file, 'w' ){ |f| f << html }
			end
		end

		# TODO: Store/copy extras from source
		# TODO: Look in template directory for 'extras' directory and copy contents
		# TODO: CHM
	end

end
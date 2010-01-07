class	DocuBot::Bundle
	attr_reader :toc, :extras
	HAML_OPTIONS     = { :format=>:html4, :ugly=>true }
	
	def initialize( source_directory )
		@source = source_directory
		@extras = []
		if !File.exists?( @source )
			raise "DocuBot cannot find directory #{File.expand_path(@source)}. Exiting."
		end
		@toc = DocuBot::Page.new( ".", "Table of Contents" )
		pages_by_path = {}
		
		source_glob = File.expand_path( File.join( @source, '**/*' ) )
		Dir[ source_glob ].each do |item|
			next if File.basename( item ) =~ /^index\.[^.]+$/
			parent = pages_by_path[ File.dirname( item ) ] || @toc
			extension = File.extname( item )[ 1..-1 ]
			item_is_page = File.directory?( item ) || DocuBot::Converter.by_type[ extension ]
			if item_is_page
				page = DocuBot::Page.new( item )
				pages_by_path[ item ] = page
				parent << page
			else
				# TODO: Anything better needed?
				@extras << item
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
		page_template = File.join( DocuBot::TEMPLATE_DIR, 'default', 'page.haml' ) unless File.exists?( page_template )
		page_template = Haml::Engine.new( IO.read( page_template ), HAML_OPTIONS )
		Dir.chdir destination do
			@toc.descendants.each do |page|
				#FIXME: Page titles may not be unique. Need to generate unique file names; associated with originals for links to work.
				file = page.title.gsub(/\W+/,'_') + '.html'
				html = page_template.render( Object.new, :page=>page )
				puts "Writing out #{file.inspect}" if $DEBUG
				File.open( file, 'w' ){ |f| f << html }
			end
		end

		# TODO: Store/copy extras from source
		# TODO: Look in template directory for 'extras' directory and copy contents
		# TODO: CHM
	end

end
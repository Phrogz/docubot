class	DocuBot::Bundle
	attr_reader :toc, :extras
	HAML_OPTIONS     = { :format=>:html4, :ugly=>true }
	
	def initialize( source_directory )
		@source = source_directory
		@extras = []
		if !File.exists?( @source )
			raise "DocuBot cannot find directory #{File.expand_path(@source)}. Exiting."
		end
		@toc = DocuBot::Page.new( @source, "Table of Contents" )
		pages_by_path = {}
		
		source_glob = File.expand_path( @source/'**/*' )
		files_and_folders = Dir[ source_glob ]
		files_and_folders.reject!{ |f| File.basename(f) =~ /^index\.[^.]+$/ }
		files_and_folders.reject!{ |f| f =~ /\b_template\b/ }
		files_and_folders.each do |item|
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
	
	# Specify nil for template to use a '_template' directory from the source
	def write( template=nil, destination=nil )
		require 'fileutils'
		
		destination ||= File.dirname(@source)/"#{File.basename @source}_html"
		Dir.mkdir(destination) unless File.exists?(destination)
		
		template_dir = if template.nil?
			@source/'_template'
		else
			DocuBot::TEMPLATE_DIR/template/'_template'
		end

		unless File.exists?( template_dir )
			warn "The specified template '#{template}' does not exist in #{DocuBot::TEMPLATE_DIRECTORY}."
			warn "Falling back to default template."
			template_dir = DocuBot::TEMPLATE_DIR/'default'/'_template'
		end

		extra_files = template_dir/'extras'
		if File.exists?( extra_files )
			FileUtils.copy( Dir[ extra_files/'*' ], destination )
		end
		
		page_template = Haml::Engine.new( IO.read( template_dir/'page.haml' ), HAML_OPTIONS )
		Dir.chdir destination do
			@toc.descendants.each do |page|
				#FIXME: Page titles may not be unique. Need to generate unique file names; associated with originals for links to work.
				file = page.title.gsub(/\W+/,'_') + '.html'
				html = page_template.render( Object.new, :page=>page, :global=>@toc )
				puts "Writing out #{file.inspect}" if $DEBUG
				File.open( file, 'w' ){ |f| f << html }
			end
		end

		# TODO: Store/copy extras from source
		# TODO: Look in template directory for 'extras' directory and copy contents
		# TODO: CHM
	end

end
class DocuBot::Bundle
	attr_reader :toc, :extras, :glossary
	HAML_OPTIONS = { :format=>:html4, :ugly=>true, :encoding=>'utf-8' }
	
	def initialize( source_directory )
		@source = File.expand_path( source_directory )
		@extras = []
		@glossary = DocuBot::Glossary.new( self )
		if !File.exists?( @source )
			raise "DocuBot cannot find directory #{@source}. Exiting."
		end
		@toc = DocuBot::Page.new( ".", "Table of Contents" )
		@toc.bundle = self
		@toc.meta['glossary'] = @glossary
		pages_by_path = {}
		
		Dir.chdir( @source ) do
			files_and_folders = Dir[ '**/*' ]
			files_and_folders.reject!{ |f| File.basename(f) =~ /^index\.[^.]+$/ }
			files_and_folders.reject!{ |f| f =~ /\b_template\b/ }
			files_and_folders.each do |item|
				parent = pages_by_path[ File.dirname( item ) ] || @toc
				extension = File.extname( item )[ 1..-1 ]
				item_is_page = File.directory?( item ) || DocuBot::Converter.by_type[ extension ]
				if item_is_page
					page = DocuBot::Page.new( item )
					page.bundle = self
					pages_by_path[ item ] = page
					parent << page
				else
					# TODO: Anything better needed?
					@extras << item
				end
			end
		end
	end
	
	# Specify nil for template to use a '_template' directory from the source
	def write( template=nil, destination=nil )
		require 'fileutils'
		
		destination ||= File.dirname(@source)/"#{File.basename @source}_html"
		FileUtils.rm_rf(destination) if File.exists?(destination)
		FileUtils.mkdir(destination)
		
		template_dir = if template.nil?
			@source/'_template'
		else
			DocuBot::TEMPLATE_DIR/template/'_template'
		end

		unless File.exists?( template_dir )
			warn "The specified template '#{template}' does not exist in #{DocuBot::TEMPLATE_DIR}."
			warn "Falling back to default template."
			template_dir = DocuBot::TEMPLATE_DIR/'default'/'_template'
		end
		template_dir = File.expand_path( template_dir )

		extra_files = template_dir/'extras'
		if File.exists?( extra_files )
			FileUtils.copy( Dir[ extra_files/'*' ], destination )
		end
		
		page_template = Haml::Engine.new( IO.read( template_dir/'top.haml' ), HAML_OPTIONS )
		Dir.chdir destination do
			@toc.descendants.each do |page|
				puts "Working on #{page.title}" if $DEBUG
				contents = page.to_html( template_dir )
				html = page_template.render( Object.new, :page=>page, :contents=>contents, :global=>@toc )
				file = page.file ? page.file.sub( /[^.]+$/, 'html' ) : File.join( page.folder, 'index.html' )
				dir  = File.dirname( file )
				FileUtils.mkdir_p( dir ) unless File.exists?( dir )
				puts "...writing out #{file.inspect}" if $DEBUG
				File.open( file, 'w' ){ |f| f << html }
			end
		end

		# TODO: Store/copy extras from source
		# TODO: Look in template directory for 'extras' directory and copy contents
		# TODO: CHM
	end

end
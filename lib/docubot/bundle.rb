# encoding: UTF-8
class DocuBot::Bundle
	attr_reader :toc, :extras, :glossary, :source, :dump_path
	HAML_OPTIONS = { :format=>:html4, :ugly=>true, :encoding=>'utf-8' }
	
	def initialize( source_directory )
		@source = File.expand_path( source_directory )
		@extras = []
		@glossary = DocuBot::Glossary.new( self )
		if !File.exists?( @source )
			raise "DocuBot cannot find directory #{@source}. Exiting."
		end
		Dir.chdir( @source ) do
			@toc = DocuBot::Page.new( ".", "Table of Contents" )
			@toc.bundle = self
			@toc.meta['glossary'] = @glossary
			pages_by_path = {}
		
			files_and_folders = Dir[ '**/*' ]
			files_and_folders.reject!{ |f| File.basename(f) =~ /^index\.[^.]+$/ || File.basename(f) == '_static' }
			files_and_folders.reject!{ |f| f =~ /\b_template\b/ }
			files_and_folders.each do |item|
				extension = File.extname( item )[ 1..-1 ]
				item_is_page = File.directory?(item) || DocuBot::Converter.by_type[extension]
				if item_is_page
					parent = pages_by_path[ File.dirname( item ) ] || @toc
					page = DocuBot::Page.new( item )
					page.bundle = self
					pages_by_path[ item ] = page
					page.hide = true if File.basename( item ) =~ /^_/ && !page.hide?
					parent << page
				else
					# TODO: Anything better needed?
					@extras << item
				end
			end
		end
	end
	
	# Specify nil for template to use a '_template' directory from the source
	def dump( template=nil, destination=nil )
		@dump_path = destination || File.dirname(@source)/"#{File.basename @source}_html"
		FileUtils.rm_rf(@dump_path) if File.exists?(@dump_path)
		FileUtils.mkdir(@dump_path)
		
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

		extra_files = template_dir/'_root'
		if File.exists?( extra_files )
			FileUtils.copy( Dir[ extra_files/'*' ], @dump_path )
		end
		
		page_template = Haml::Engine.new( IO.read( template_dir/'top.haml' ), HAML_OPTIONS )
		Dir.chdir @dump_path do
			@toc.descendants.each do |page|
				puts( "Working on #{page.title}" ) if $DEBUG
				contents = page.to_html( template_dir )
				root = "../" * page.depth
				html = page_template.render( Object.new, :page=>page, :contents=>contents, :global=>@toc, :root=>root )
				dir  = File.dirname( page.html_path )
				FileUtils.mkdir_p( dir ) unless File.exists?( dir )
				puts( "...writing out #{page.html_path.inspect}" ) if $DEBUG
				File.open( page.html_path, 'w' ){ |f| f << html }
			end
		end
		
		@extras.each do |file|
			dir = @dump_path / File.dirname( file )
			FileUtils.mkdir_p( dir ) unless File.exists?( dir )
			FileUtils.cp( @source / file, @dump_path / file )
		end

		# TODO: Store/copy extras from source
		# TODO: Look in template directory for 'extras' directory and copy contents
		# TODO: CHM
		
		@dump_path
	end

	# Specify nil for template to use a '_template' directory from the source
	def write( writer_type, template=nil, dump_path=nil )
		self.dump( template, dump_path )
		chm_path = "#{@source}.chm"
		DocuBot.write_bundle( self, writer_type, chm_path )
	end

end
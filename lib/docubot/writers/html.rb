class DocuBot::HTMLWriter < DocuBot::Writer
	handles_type :html
	
	# Specify nil for template to use a '_template' directory from the source.
	# Specify nil for destination to place "<source>_html" next to the source.
	def write( template=nil, destination=nil )
		source = @bundle.source
		@html_path = destination || File.dirname(source)/"#{File.basename source}_html"
		FileUtils.rm_rf(@html_path) if File.exists?(@html_path)
		FileUtils.mkdir(@html_path)
		
		# Find a valid template directory, preferring _template in the documentation source
		template_dir = template ? DocuBot::TEMPLATE_DIR/template/'_template' : source/'_template'
		unless File.exists?( template_dir )
			template_dir = DocuBot::TEMPLATE_DIR/'default'/'_template'
			warn "The specified template '#{template}' does not exist in #{DocuBot::TEMPLATE_DIR}." if template
			warn "Using default template from #{template_dir}."
		end
		template_dir = File.expand_path( template_dir )

		# Copy any files found in the source directory that weren't made into pages
		@bundle.extras.each do |file|
			FileUtils.mkdir_p( @html_path / File.dirname( file ) )
			FileUtils.cp( source / file, @html_path / file )
		end
		
		# Copy files from template to root of destination
		# Record these as extras so that the CHMWriter can access them
		Dir.chdir @html_path do
			existing_files = Dir[ '*' ]
			FileUtils.copy( Dir[ template_dir/'_root'/'*' ], '.' )
			new_files = Dir[ '*' ] - existing_files
			@bundle.extras.concat( new_files )
		end
				
		Dir.chdir @html_path do
			o = Object.new
			
			# Write out every page
			page_template = Haml::Engine.new( IO.read( template_dir/'top.haml' ), HAML_OPTIONS )
			@bundle.toc.descendants.each do |page|
				contents = page.to_html( template_dir )
				root = "../" * page.depth
				html = page_template.render( o, :page=>page, :contents=>contents, :global=>@bundle.toc, :root=>root )
				FileUtils.mkdir_p( File.dirname( page.html_path ) )
				File.open( page.html_path, 'w' ){ |f| f << html }
			end

			# Write out the TOC (even though the CHM won't use it, others may)
			File.open( '_toc.html', 'w' ) do |f|
				template = Haml::Engine.new( IO.read( template_dir/'toc.haml' ), HAML_OPTIONS )
				f << template.render( o, :toc=>@bundle.toc, :global=>@bundle.toc, :root=>'' )
			end
		end
		
	end
end

module Haml::Helpers
	def li_pages_for( page )
		page.pages.each do |child|
			haml_tag :li do
				haml_tag :a, :href=>child.html_path do
					haml_concat child.title
				end
				unless child.leaf?
					haml_tag :ul do
						li_pages_for child
					end
				end
			end
		end
	end
end
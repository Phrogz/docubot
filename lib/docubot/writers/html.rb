class DocuBot::HTMLWriter < DocuBot::Writer
	handles_type :html
	
	# Specify nil for destination to place "<source>_html" next to the source.
	def write( destination=nil )
		start = Time.now
		
		source = @bundle.source
		@html_path = destination || File.dirname(source)/"#{File.basename source}_html"
		FileUtils.rm_rf(@html_path) if File.exists?(@html_path)
		FileUtils.mkdir(@html_path)
		
		master_templates = DocuBot::TEMPLATE_DIR
		source_templates = source/'_templates'
		
		# Copy any files found in the source directory that weren't made into pages
		@bundle.extras.each do |file|
			FileUtils.mkdir_p( @html_path / File.dirname( file ) )
			FileUtils.cp( source / file, @html_path / file )
		end
		
		# Copy files from template to root of destination
		# Record these as extras so that the CHMWriter can access them
		Dir.chdir @html_path do
			existing_files = Dir[ '*' ]
			FileUtils.copy( Dir[ master_templates/'_root'/'*' ], '.' )
			FileUtils.copy( Dir[ source_templates/'_root'/'*' ], '.' )
			new_files = Dir[ '*' ] - existing_files
			@bundle.extras.concat( new_files )
		end
		
		Dir.chdir @html_path do
			o = Object.new
			
			# Write out every page
			template = File.exists?( source_templates/'top.haml' ) ? source_templates/'top.haml' : master_templates/'top.haml'
			template = Haml::Engine.new( IO.read( template ), HAML_OPTIONS )
			@bundle.toc.descendants.each do |page|
				next if page.sublink?
				contents = page.to_html
				root = "../" * page.depth
				html = template.render( o, :page=>page, :contents=>contents, :global=>@bundle.toc, :root=>root )
				FileUtils.mkdir_p( File.dirname( page.html_path ) )
				File.open( page.html_path, 'w' ){ |f| f << html }
			end

			# Write out the TOC and Index (even though the CHM won't use them, others may)
			{ 'toc.haml'=>'_toc.html', 'index.haml'=>'_index.html' }.each do |haml,output|
				File.open( output, 'w' ) do |f|
					template = File.exists?( source_templates/haml ) ? source_templates/haml : master_templates/haml
					template = Haml::Engine.new( IO.read( template ), HAML_OPTIONS )
					f << template.render( o, :toc=>@bundle.toc, :global=>@bundle.toc, :root=>'' )
				end
			end
			
			File.open( 'glossary-terms.js', 'w' ){ |f| f << @bundle.glossary.to_js }
		end
		
		puts "...%.2fs to write the HTML" % (Time.now - start)
	end
end

module Haml::Helpers
	def li_pages_for( page )
		page.pages.each do |child|
			haml_tag :li do
				haml_tag :a, :href=>child.html_path do
					haml_concat child.title
				end
				unless child.pages.empty?
					haml_tag :ul do
						li_pages_for child
					end
				end
			end
		end
	end
end
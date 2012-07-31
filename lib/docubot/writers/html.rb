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
		master_root = master_templates/'_root'
		source_root = source_templates/'_root'
		
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
			top = File.exists?( source_templates/'top.haml' ) ? source_templates/'top.haml' : master_templates/'top.haml'
			top = Haml::Engine.new( IO.read( top, encoding:'utf-8' ), HAML_OPTIONS )
			@bundle.toc.descendants.each do |node|
				next if node.anchor
				
				contents = node.page.to_html
				template = node.page.template # Call page.to_html first to ensure page.template is set

				custom_js = "#{template}.js"
				custom_js = nil unless File.exists?( source_root/custom_js ) || File.exists?( master_root/custom_js )
				
				custom_css = "#{template}.css"
				custom_css = nil unless File.exists?( source_root/custom_css ) || File.exists?( master_root/custom_css )
				
				variables = {
					:page       => node.page,
					:contents   => contents,
					:global     => @bundle.global,
					:root       => node.page.root,
					:breadcrumb => node.ancestors,
					:custom_js  => custom_js,
					:custom_css => custom_css
				}				
				html = top.render( o, variables )
				FileUtils.mkdir_p( File.dirname( node.file ) )
				File.open( node.file, 'w' ){ |f| f << html }
			end

			File.open( 'glossary-terms.js', 'w' ){ |f| f << @bundle.glossary.to_js }
		end
		
		puts "...%.2fs to write the HTML" % (Time.now - start)
	end
end

module Haml::Helpers
	def li_pages_for( node )
		node.children.each do |child|
			haml_tag :li, :class=>(child.anchor ? 'sublink' : child.children.empty? ? 'section' : 'page' ) do
				haml_tag :a, :href=>child.link do
					haml_concat child.title
				end
				unless child.children.empty?
					haml_tag :ul do
						li_pages_for child
					end
				end
			end
		end
	end
end
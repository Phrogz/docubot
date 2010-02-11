# encoding: UTF-8
require 'pathname'
class DocuBot::Bundle
	attr_reader :toc, :extras, :glossary, :index, :source, :global
	attr_reader :internal_links, :external_links, :file_links, :broken_links
	attr_reader :pages, :pages_by_title, :page_by_file_path, :page_by_html_path
	def initialize( source_directory )
		@source = File.expand_path( source_directory )
		raise "DocuBot cannot find directory #{@source}. Exiting." unless File.exists?( @source )
		@pages  = []
		@extras = []
		@pages_by_title    = Hash.new{ |h,k| h[k]=[] }
		@page_by_file_path = {}
		@page_by_html_path = {}

		@glossary = DocuBot::Glossary.new( self, @source/'_glossary' )
		@index    = DocuBot::Index.new( self )
		@toc      = DocuBot::LinkTree::Root.new( self )

		Dir.chdir( @source ) do
			# This might be nil; MetaSection.new is OK with that.
			index_file = Dir[ *DocuBot::Converter.types.map{|t| "index.#{t}"} ][ 0 ]
			@global = DocuBot::MetaSection.new( {:title=>'DocuBot Documentation'}, index_file )
			@global.glossary = @glossary
			@global.index    = @index
			@global.toc      = @toc

			files_and_folders = Dir[ '**/*' ]
			
			# index files are handled by Page.new for a directory; no sections for special folders (but process contents)
			files_and_folders.reject!{ |path| name = File.basename( path ); name =~ /^(?:index\.[^.]+)$/ }
			
			# All files in the _templates directory should be ignored
			files_and_folders.reject!{ |f| f =~ /(?:^|\/)_/ }
			files_and_folders.concat Dir[ '_static/**/*' ]
			files_and_folders.concat Dir[ '_glossary/**/*' ]

			@global.ignore.as_list.each do |glob|
				files_and_folders = files_and_folders - Dir[glob]
			end
			
			create_pages( files_and_folders )			
		end
		# puts @toc.to_txt
		
		# Regenerate pages whose templates require full scaning to have completed
		# TODO: make this based off of a metasection attribute.
		@pages.select do |page|
			%w[ glossary ].include?( page.template )
		end.each do |page|
			page.dirty_template
		end
		
		# TODO: make this optional via global variable
		validate_links
		warn_for_broken_links
		
		# TODO: make this optional via global variable
		warn_for_missing_glossary_terms
		
		find_page_collisions
	end
	
	def create_pages( files_and_folders )
		files_and_folders.each do |path|
			extension = File.extname( path )[ 1..-1 ]
			item_is_page = File.directory?(path) || DocuBot::Converter.by_type[extension]
			if !item_is_page
				@extras << path
			else
				page = DocuBot::Page.new( self, path )

				if path =~ %r{^_glossary/}
					@glossary << page
				else
					@pages                            << page
					@page_by_file_path[path]           = page
					@page_by_html_path[page.html_path] = page
					@pages_by_title[page.title]       << page
					@index.process_page( page )

					# Add the page (and any sub-links) to the toc
					unless page.hide
						@toc.add_to_link_hierarchy( page.title, page.html_path, page )
						page.toc.as_list.each do |id_or_text|
							id = id_or_text[0..0] == '#' ? id_or_text : DocuBot.id_from_text(id_or_text)
							if ele = page.nokodoc.at_css(id)
								@toc.add_to_link_hierarchy( ele.inner_text, page.html_path + id, page )
							else
								warn "Could not find requested toc anchor #{id.inspect} based on #{id_or_text.inspect} on #{page.html_path}"
							end
						end
					end
					
				end
			end
		end		
	end

	def validate_links
		@external_links = Hash.new{ |h,k| h[k]=[] }
		@internal_links = Hash.new{ |h,k| h[k]=[] }
		@file_links     = Hash.new{ |h,k| h[k]=[] }
		@broken_links   = Hash.new{ |h,k| h[k]=[] }

		Dir.chdir( @source ) do 
			@pages.each do |page|
				# TODO: set the xpath to .//a/@href once this is fixed: http://github.com/tenderlove/nokogiri/issues/#issue/213
				page.nokodoc.xpath('.//a').each do |a|
					next unless href = a['href']
					href = CGI.unescape(href)
					if href=~%r{^[a-z]+://}i
						@external_links[page] << href
					else
						id   = href[/#([a-z][\w.:-]*)?/i]
						file = href.sub(/#.*/,'')
						path = file.empty? ? page.html_path : Pathname.new( File.dirname(page.html_path) / file ).cleanpath.to_s
						if target=@page_by_html_path[path]
							if !id || id == "#" || target.nokodoc.at_css(id)
								@internal_links[page] << href
							else
								warn "Could not find internal link for #{id.inspect} on #{page.html_path.inspect}" if id 
								@broken_links[page] << href
							end
						else
							if File.file?(path) && !@page_by_file_path[path]
								@file_links[page] << href
							else
								@broken_links[page] << href
							end
						end
					end
				end
			end
		end
	end
	
	def warn_for_broken_links
		@broken_links.each do |page,links|
			links.each do |link|
				warn "Broken link on #{page.file}: '#{link}'"
			end
		end
	end
	
	def warn_for_missing_glossary_terms
		@glossary.missing_terms.each do |term,referrers|
			warn "Glossary term '#{term}' never defined."
			referrers.each do |referring_page|
				warn "...seen on #{referring_page.file}."
			end
		end		
	end
	
	def find_page_collisions
		# Find any and all pages that would collide
		pages_by_html_path = Hash.new{ |h,k| h[k] = [] }
		@pages.each do |page|
			pages_by_html_path[page.html_path] << page
		end
		collisions = pages_by_html_path.select{ |path,pages| pages.length>1 }
		unless collisions.empty?
			message = collisions.map do |path,pages|
				"#{path}: #{pages.map{ |page| "'#{page.title}' (#{page.file})" }.join(', ')}"
			end.join("\n")
			raise PageCollision.new, message
		end		
	end

	def write( writer_type, destination=nil )
		writer = DocuBot::Writer.by_type[ writer_type.to_s.downcase ]
		if writer
			writer.new( self ).write( destination )
		else
			raise "Unknown writer '#{writer_type}'; available types: #{DocuBot::Writer::INSTALLED_WRITERS.join ', '}"
		end
	end
	
end

class DocuBot::Bundle::PageCollision < RuntimeError; end


# encoding: UTF-8
class DocuBot::Bundle
	attr_reader :toc, :extras, :glossary, :index, :source
	
	def initialize( source_directory )
		@source = File.expand_path( source_directory )
		raise "DocuBot cannot find directory #{@source}. Exiting." unless File.exists?( @source )
		@extras = []
		@glossary = DocuBot::Glossary.new( self, @source/'_glossary' )
		@index    = DocuBot::Index.new( self )
		Dir.chdir( @source ) do
			@toc = DocuBot::Page.new( self, ".", "Table of Contents" )
			@toc.meta['glossary'] = @glossary
			@toc.meta['index']    = @index
			pages_by_path = { '.'=>@toc }
		
			files_and_folders = Dir[ '**/*' ]
			files_and_folders.reject!{ |f| File.basename(f) =~ /^index\.[^.]+$/ || File.basename(f) == '_static' || File.basename(f) == '_glossary' }
			files_and_folders.reject!{ |f| f =~ /\b_templates\b/ }
			files_and_folders.each do |item|
				extension = File.extname( item )[ 1..-1 ]
				item_is_page = File.directory?(item) || DocuBot::Converter.by_type[extension]
				if item_is_page
					parent = pages_by_path[ File.dirname( item ) ]
					page = DocuBot::Page.new( self, item )
					pages_by_path[ item ] = page
					parent << page if parent
					if item =~ /\b_glossary\b/
						@glossary << page 
					end
					@index.process_page( page )
					
					# TODO: Move this bloat elsewhere.
					if page.toc?
						ndoc = page.nokodoc
						toc = page.toc
						ids = if toc[','] # Comma-delimited toc interpreted as generated ids
							toc.split(/,\s*/).map{ |title| DocuBot.id_from_text(title) }
						else
							toc.scan /[a-z][\w.:-]*/i
						end
 						ids.each do |id|
							if ele = ndoc.at_css("##{id}")
								page << DocuBot::SubLink.new( page, ele.inner_text, id )
							else
								warn "Could not find requested toc anchor '##{id}' on #{page.html_path}"
							end
						end
					end
					
				else
					# TODO: Anything better needed?
					@extras << item
				end
			end
		end
	end
	
	def write( writer_type, destination=nil)
		writer = DocuBot::Writer.by_type[ writer_type.to_s.downcase ]
		if writer
			writer.new( self ).write( destination )
			unless @glossary.missing_terms.empty?
				warn "The following glossary terms were never defined:\n#{@glossary.missing_terms.map{|t|t.inspect}.join(', ')}"
			end			
		else
			raise "Unknown writer '#{writer_type}'; available types: #{DocuBot::Writer::INSTALLED_WRITERS.join ', '}"
		end
	end
	
end
# encoding: UTF-8
class DocuBot::Bundle
	attr_reader :toc, :extras, :glossary, :source, :dump_path
	
	def initialize( source_directory )
		@source = File.expand_path( source_directory )
		@extras = []
		@glossary = DocuBot::Glossary.new( self, @source/'_glossary' )
		if !File.exists?( @source )
			raise "DocuBot cannot find directory #{@source}. Exiting."
		end
		Dir.chdir( @source ) do
			@toc = DocuBot::Page.new( ".", "Table of Contents" )
			@toc.bundle = self
			@toc.meta['glossary'] = @glossary
			pages_by_path = {}
		
			files_and_folders = Dir[ '**/*' ]
			files_and_folders.reject!{ |f| File.basename(f) =~ /^index\.[^.]+$/ || File.basename(f) == '_static' || File.basename(f) == '_glossary' }
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
					@glossary << page if item =~ /\b_glossary\b/
				else
					# TODO: Anything better needed?
					@extras << item
				end
			end
		end
	end
	
	def write( writer_type, template=nil, destination=nil)
		writer = DocuBot::Writer.by_type[ writer_type.to_s.downcase ]
		if writer
			writer.new( self ).write( template, destination )
			unless @glossary.missing_terms.empty?
				warn "The following glossary terms were never defined:\n#{@glossary.missing_terms.map{|t|t.inspect}.join(', ')}"
			end			
		else
			raise "Unknown writer '#{writer_type}'; available types: #{DocuBot::Writer::INSTALLED_WRITERS.join ', '}"
		end
	end
	
end
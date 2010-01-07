require 'yaml'
class DocuBot::Page
	META_SEPARATOR = /^\+\+\+$/ # Sort of like +++ATH0

	attr_reader :html, :pages
	attr_accessor :parent

	def initialize( source_path, title=nil, type=nil )
		# puts "#{self.class}.new( #{source_path.inspect}, #{title.inspect}, #{type.inspect} )"
		title ||= File.basename( source_path ).sub( /\.[^.]+$/, '' ).sub( /^\d*\s/, '' )
		@meta = { 'title'=>title }
		@source = source_path
		@pages = []
		if File.directory?( @source )
			if source_path = Dir[ File.join( source_path, 'index.*' ) ][0]
				@source = source_path
			end
		end

		type ||= File.extname( @source )[ 1..-1 ]
		unless File.directory?( @source )
			parts = File.read( @source ).split( META_SEPARATOR, 2 )
			@meta.merge!( YAML.load( parts.first ) ) if parts.length > 1
			@html = DocuBot::convert_to_html( parts.last, type )
			@html = DocuBot::process_snippets( @html )
		end
	end

	def method_missing( method, *args )
		key=method.to_s
		case key[-1..-1]
			when '?' then @meta.has_key?( key[0..-2] )
			when '!', '=' then super
			else @meta[ key ]
		end
	end
	
	def to_s( depth=0 )
		(["#{'  '*depth}#{@meta['title']}"] + @pages.map{ |e| e.to_s(depth+1) }).join("\n")
	end
	
	def sub_sections
		@pages.reject{ |e| e.pages.empty? }
	end
	def pages
		@pages.select{ |e| e.pages.empty? }
	end
	def every_page
		(pages + sub_sections.map{ |sub| sub.every_page }).flatten
	end
	def every_section
		(sub_sections + sub_sections.map{ |sub| sub.every_section }).flatten
	end
	def descendants
		(@pages + @pages.map{ |page| page.pages }).flatten
	end
	def <<( entry )
		@pages << entry
		entry.parent = self
	end
end

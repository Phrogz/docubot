require 'yaml'
class DocuBot::Page
	META_SEPARATOR = /^\+\+\+\s*$/u # Sort of like +++ATH0

	attr_reader :pages, :type
	attr_accessor :parent

	def initialize( source_path, title=nil, type=nil )
		puts "#{self.class}.new( #{source_path.inspect}, #{title.inspect}, #{type.inspect} )" if $DEBUG
		title ||= File.basename( source_path ).sub( /\.[^.]+$/, '' ).sub( /^\d*\s/, '' )
		@meta = { 'title'=>title }
		@source = source_path
		@pages = []
		if File.directory?( @source )
			if source_path = Dir[ source_path/'index.*' ][0]
				@source = source_path
			end
		end

		@type = type || File.extname( @source )[ 1..-1 ]
		unless File.directory?( @source )
			parts = IO.read_utf8( @source ).split( META_SEPARATOR, 2 )
			
			if parts.length > 1
				yaml = parts.first
				# Make YAML friendler to n00bs
				yaml.gsub!( /^\t/, '  ' )
				yaml = YAML.load( yaml )
				@meta.merge!( yaml ) 
			end
			# Raw markup untransformed
			@raw = parts.last
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
	
	def sections
		@pages.reject{ |e| e.pages.empty? }
	end
	def leafs
		@pages.select{ |e| e.pages.empty? }
	end
	def every_leaf
		(leafs + sub_sections.map{ |sub| sub.every_leaf }).flatten
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
	def leaf?
		@pages.empty?
	end
	
	def to_html( template_dir )
		contents = if @raw
			DocuBot::process_snippets( DocuBot::convert_to_html( @raw, @type, template_dir ) )
		end
		layout = @meta['layout'] || ( leaf? ? 'page' : 'section' )
		template = Haml::Engine.new( IO.read_utf8( template_dir / "#{layout}.haml" ), DocuBot::Bundle::HAML_OPTIONS )
		template.render( Object.new, :contents=>contents, :page=>self ).force_encoding( 'utf-8' )
	end
		
end

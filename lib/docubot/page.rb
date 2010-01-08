# encoding: UTF-8
require 'yaml'
class DocuBot::Page
	META_SEPARATOR = /^\+\+\+\s*$/ # Sort of like +++ATH0

	attr_reader :pages, :type, :folder, :file, :meta
	attr_accessor :parent, :bundle

	def initialize( source_path, title=nil, type=nil )
		puts "#{self.class}.new( #{source_path.inspect}, #{title.inspect}, #{type.inspect} )" if $DEBUG
		title ||= File.basename( source_path ).sub( /\.[^.]+$/, '' ).sub( /^\d*\s/, '' )
		@meta  = { 'title'=>title }
		@pages = []
		@file  = source_path
		if File.directory?( @file )
			@folder = @file
			@file   = Dir[ source_path/'index.*' ][0]
		else
			@folder = File.dirname( @file )
		end

		# Directories without an index file have no @file
		if @file
			@type = type || File.extname( @file )[ 1..-1 ]
			parts = IO.read_utf8( @file ).split( META_SEPARATOR, 2 )
			
			if parts.length > 1
				# Make YAML friendler to n00bs
				yaml = YAML.load( parts.first.gsub( /^\t/, '  ' ) )
				@meta.merge!( yaml ) 
			end
			
			# Raw markup, untransformed
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
		contents = @raw && DocuBot::process_snippets( DocuBot::convert_to_html( @raw, @type ) )
		layout = @meta['kind'] || ( leaf? ? 'page' : 'section' )
		template = Haml::Engine.new( IO.read_utf8( template_dir / "#{layout}.haml" ), DocuBot::Bundle::HAML_OPTIONS )
		template.render( Object.new, :contents=>contents, :page=>self, :global=>@bundle.toc ).encode( 'utf-8', :undef=>:replace )
	end
		
end

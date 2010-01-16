# encoding: UTF-8
require 'yaml'
require 'nokogiri'

class DocuBot::Page
	META_SEPARATOR = /^\+\+\+\s*$/ # Sort of like +++ATH0

	attr_reader :pages, :type, :folder, :file, :meta
	attr_accessor :parent, :bundle

	def initialize( source_path, title=nil, type=nil )
		puts "#{self.class}.new( #{source_path.inspect}, #{title.inspect}, #{type.inspect} )" if $DEBUG
		title ||= File.basename( source_path ).sub( /\.[^.]+$/, '' ).gsub( '_', ' ' ).sub( /^\d+\s/, '' )
		@meta  = { 'title'=>title }
		@pages = []
		@file  = source_path
		if File.directory?( @file )
			@folder = @file
			# WILL SET @file TO NIL FOR DIRECTORIES WITHOUT AN INDEX.* FILE
			@file   = Dir[ source_path/'index.*' ][0]
		else
			@folder = File.dirname( @file )
		end

		# Directories without an index file have no @file
		if @file
			@type = type || File.extname( @file )[ 1..-1 ]
			parts = IO.read( @file ).split( META_SEPARATOR, 2 )
			
			if parts.length > 1
				# Make YAML friendler to n00bs
				yaml = YAML.load( parts.first.gsub( /^\t/, '  ' ) )
				@meta.merge!( yaml )
			end
			
			# Raw markup, untransformed
			@raw = parts.last
		end
	end
	def []( key )
		@meta[key]
	end

	def method_missing( method, *args )
		key=method.to_s
		case key[-1..-1] # the last character of the method name
			when '?' then @meta.has_key?( key[0..-2] )
			#when '=' then @meta[ key[0..-2] ] = args[0]
			when '!','=' then super
			else @meta[ key ]
		end
	end
	def ancestors
		page = self
		anc = []
		anc.unshift( page ) while page = page.parent
		anc
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
		(@pages + @pages.map{ |page| page.descendants }).flatten
	end
	alias_method :every_page, :descendants
	def <<( entry )
		@pages << entry
		entry.parent = self
	end
	def leaf?
		@pages.empty? || @pages.all?{ |x| x.is_a?(DocuBot::SubLink) }
	end
	def depth
		@_depth ||= @file ? @file.count('/') : @folder.count('/') + 1
	end
	def root
		@_root ||= "../" * depth
	end
	def html_path
		@file ? @file.sub( /[^.]+$/, 'html' ) : ( @folder / 'index.html' )
	end
	def to_html
		return @cached_html if @cached_html

		contents = if @raw
			# Directories with no index.* file will not have any @raw
			html = DocuBot::convert_to_html( self, @raw, @type )
			DocuBot::process_snippets( self, html )
		end

		@meta['template'] ||= leaf? ? 'page' : 'section'

		master_templates = DocuBot::TEMPLATE_DIR
		source_templates = @bundle.source / '_templates'

		haml = source_templates / "#{template}.haml"
		haml = master_templates / "#{template}.haml" unless File.exists?( haml )
		haml = master_templates / "page.haml"        unless File.exists?( haml )
		haml = Haml::Engine.new( IO.read( haml ), DocuBot::Writer::HAML_OPTIONS )
		contents = haml.render( Object.new, :contents=>contents, :page=>self, :global=>@bundle.toc, :root=>root )

		@cached_html = contents
	end
	def to_html!
		@cached_html=nil
		to_html
	end
	def nokodoc
		@nokodoc ||= Nokogiri::HTML(to_html)
	end
	def nokodoc!
		@nokodoc ||= Nokogiri::HTML(to_html!)
	end
end

class DocuBot::SubLink
	attr_reader :page, :title, :id
	def initialize( page, title, id )
		@page, @title, @id = page, title, id
	end
	def html_path
		"#{@page.html_path}##{@id}"
	end
	def leaf?
		true
	end
	def pages
		[]
	end
	alias_method :descendants, :pages
	def depth
		@page.depth
	end
	def parent
		@page
	end
	def parent=( page )
		@page = page
	end
	def to_html
		""
	end
	def ancestors
		@page.ancestors
	end
	alias_method :to_html!, :to_html
	def method_missing(*args)
		nil
	end
	def hide
		false
	end
	def sublink?
		true
	end
end

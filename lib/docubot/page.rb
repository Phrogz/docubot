# encoding: UTF-8
require 'yaml'
require 'nokogiri'

class DocuBot::Page
	META_SEPARATOR = /^\+\+\+\s*$/ # Sort of like +++ATH0
	AUTO_ID_ELEMENTS = %w[ h1 h2 h3 h4 h5 h6 legend caption dt ].join(',')

	attr_reader :pages, :type, :folder, :file, :meta, :nokodoc, :bundle
	attr_accessor :parent

	def initialize( bundle, source_path, title=nil )
		puts "#{self.class}.new( #{source_path.inspect}, #{title.inspect}, #{type.inspect} )" if $DEBUG
		title ||= File.basename( source_path ).sub( /\.[^.]+$/, '' ).gsub( '_', ' ' ).sub( /^\d+\s/, '' )
		@bundle = bundle
		@meta  = { 'title'=>title }
		@pages = []
		@file  = source_path
		if File.directory?( @file )
			@folder = @file
			@file   = Dir[ source_path/'index.*' ][0]
			# Directories without an index.* file now have nil @file
		else
			@folder = File.dirname( @file )
		end
		slurp_file_contents if @file
		create_nokodoc
	end
	
	def slurp_file_contents
		@type = File.extname( @file )[ 1..-1 ]
		parts = IO.read( @file ).split( META_SEPARATOR, 2 )
		
		if parts.length > 1
			# Make YAML friendler to n00bs
			yaml = YAML.load( parts.first.gsub( /^\t/, '  ' ) )
			@meta.merge!( yaml )
		end
		
		# Raw markup, untransformed, needs content
		if @raw = parts.last && parts.last.strip
			@raw = nil if @raw.empty?
		end
	end
	
	def create_nokodoc
		# Directories with no index.* file will not have any @raw
		# Pages with metasection only will also not have any @raw
		html = if @raw && !@raw.empty?
			html = DocuBot::process_snippets( self, @raw )
			html = DocuBot::convert_to_html( self, html, @type )
		end
		@nokodoc = Nokogiri::HTML(html || "")
		auto_id
		auto_section		
	end

	# Add IDs to elements that don't have them
	def auto_id
		# ...but only if a toc entry might reference one, or requested.
		if (@meta['auto-id']==true) || (@meta['toc'] && @meta['toc'][','])
			@nokodoc.css( AUTO_ID_ELEMENTS ).each do |node|
				next if node.has_attribute?('id')
				node['id'] = DocuBot.id_from_text(node.inner_text)
			end
			dirty_doc
		end
	end
	
	# Wrap siblings of headers in <div class='section'>
	def auto_section
		return if @meta['auto-section']==false
		return unless body = @nokodoc.at_css('body')
		
		#TODO: Make this a generic nokogiri call on any node (like body) where you can pass in a hierarchy of elements and a wrapper
		stack = []
		body.children.each do |node|
			# non-matching nodes will get level of 0
			level = node.name[ /h([1-6])/i, 1 ].to_i
			level = 99 if level == 0

			stack.pop while (top=stack.last) && top[:level]>=level
			stack.last[:div].add_child( node ) if stack.last
			if level<99
				div = Nokogiri::XML::Node.new('div',@nokodoc)
				div.set_attribute( 'class', 'section' )
				node.add_next_sibling(div)
				stack << { :div=>div, :level=>level }
			end
		end
		dirty_doc
	end

	def []( key )
		@meta[key]
	end

	def method_missing( method, *args )
		key=method.to_s
		case key[-1..-1] # the last character of the method name
			when '?' then @meta.has_key?( key[0..-2] )
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
		@_depth ||= self==@bundle.toc ? 0 : @file ? @file.count('/') : @folder.count('/') + 1
	end
	
	def root
		@_root ||= "../" * depth
	end
	
	def html_path
		@file ? @file.sub( /[^.]+$/, 'html' ) : ( @folder / 'index.html' )
	end
	
	def to_html
		html_in_template
	end

	# Call this after modifying the structure of the nokodoc for the page
	def dirty_doc
		@content_html = nil
	end
	
	def content_html
		# Nokogiri 'helpfully' wraps our content in a full HTML page
		# but apparently doesn't create a body for no content.
		@content_html ||= (body=@nokodoc.at_css('body')) && body.children.to_html
	end

	def to_html
		#TODO: cache this is people keep calling to_html and it's a problem
		@meta['template'] ||= leaf? ? 'page' : 'section'

		master_templates = DocuBot::TEMPLATE_DIR
		source_templates = @bundle.source / '_templates'
		
		tmpl = source_templates / "#{template}.haml"
		tmpl = master_templates / "#{template}.haml" unless File.exists?( tmpl )
		tmpl = master_templates / "page.haml"        unless File.exists?( tmpl )
		haml = Haml::Engine.new( IO.read( tmpl ), DocuBot::Writer::HAML_OPTIONS )
		haml.render( Object.new, :contents=>content_html, :page=>self, :global=>@bundle.toc, :root=>root )
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

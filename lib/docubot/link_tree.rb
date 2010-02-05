# encoding: UTF-8
module DocuBot::LinkTree; end

class DocuBot::LinkTree::Node
	attr_accessor :title, :link, :page, :parent
	
	def initialize( title=nil, link=nil, page=nil )
		@title,@link,@page = title,link,page
		@children = []
	end
	
	def anchor
		@link[/#(.+)/,1]
	end
	
	def file
		@link.sub(/#.+/,'')
	end
	
	def leaf?
		!@children.any?{ |node| node.page != @page }
	end

	# Add a new link underneath a link to its logical parent
	def add_to_link_hierarchy( title, link, page=nil )
		node = DocuBot::LinkTree::Node.new( title, link, page )
		parent_link = if node.anchor
			node.file
		elsif File.basename(link)=='index.html'
			File.dirname(File.dirname(link))/'index.html'
		else
			(File.dirname(link) / 'index.html')
		end
		#puts "Adding #{title.inspect} (#{link}) to hierarchy under #{parent_link}"
		parent = descendants.find{ |n| n.link==parent_link } || self
		parent << node
	end

	def <<( node )
		node.parent = self
		@children << node
	end
	
	def []( child_index )
		@children[child_index]
	end
	
	def children( parent_link=nil, &block )
		if parent_link
			root = find( parent_link )
			root ? root.children( &block ) : []
		else
			@children
		end
	end
	
	def descendants
		( @children + @children.map{ |child| child.descendants } ).flatten
	end
	
	def find( link )
		# TODO: this is eminently cachable
		descendants.find{ |node| node.link==link }
	end
	
	def depth
		# Cached assuming no one is going to shuffle the nodes after placement
		@depth ||= ancestors.length
	end
	
	def ancestors
		# Cached assuming no one is going to shuffle the nodes after placement
		return @ancestors if @ancestors
		@ancestors = []
		node = self
		@ancestors << node while node = node.parent
		@ancestors.reverse!
	end
	
	def to_s
		"#{@title} (#{@link}) - #{@page && @page.title}"
	end
	
	def to_txt( depth=0 )
		indent = "  "*depth
		[
			indent+to_s,
			children.map{|kid|kid.to_txt(depth+1)}
		].flatten.join("\n")
	end
end

class DocuBot::LinkTree::Root < DocuBot::LinkTree::Node
	undef_method :title
	undef_method :link
	undef_method :page
	attr_reader :bundle
	def initialize( bundle )
		@bundle   = bundle
		@children = []
	end

	def <<( node )
		node.parent = nil
		@children << node
	end
	
	def to_s
		"(Table of Contents)"
	end
end

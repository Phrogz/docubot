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

	# Add a new link underneath a link to its logical parent
	def add_to_link_hierarchy( title, link, page=nil )
		node = DocuBot::LinkTree::Node.new( title, link, page )
		parent_link = node.anchor ? node.file : (File.dirname(link) / 'index.html')
		parent = descendants.find{ |node| node.link==parent_link } || self
		parent << node
	end

	def <<( node )
		node.parent = self
		@children << node
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
		# Assuming no one is going to shuffle the nodes after placement
		@depth ||= ancestors.length
	end
	
	def ancestors
		ancestors = []
		node = self
		ancestors << node while node = node.parent
		ancestors.reverse!
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
end

class DocuBot::Section
	attr_reader :entries, :title
	def initialize( title )
		@entries = []
		@title   = title
	end
	def sub_sections
		@entries.select{ |e| e.is_a?( DocuBot::Section ) }
	end
	def pages
		@entries.select{ |e| e.is_a?( DocuBot::Page ) }
	end
	def every_page
		(pages + sub_sections.map{ |sub| sub.every_page }).flatten
	end
	def every_section
		(sub_sections + sub_sections.map{ |sub| sub.every_section }).flatten
	end
	def <<( entry )
		@entries << entry
	end
	def to_s( depth=0 )
		(["#{'  '*depth}#@title"] + @entries.map{ |e| e.to_s(depth+1) }).join("\n")
	end
end

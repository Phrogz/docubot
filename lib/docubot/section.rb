class DocuBot::Section
	attr_reader :entries, :title
	def initialize( title )
		@entries = []
		@title   = title
	end
	def sub_sections
		@entries.select{ |e| e.is_a?( DocuBot::Section ) }
	end
	def <<( entry )
		@entries << entry
	end
	def to_s( depth=0 )
		(["#{'  '*depth}#@title"] + @entries.map{ |e| e.to_s(depth+1) }).join("\n")
	end
end

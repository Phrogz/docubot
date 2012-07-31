# encoding: UTF-8
class DocuBot::MetaSection; end
module DocuBot::MetaSection::Castable
	def as_boolean
		self == 'true'
	end
	def as_list
		return [] if self.nil?
		# Replace commas inside quoted strings with unlikely-to-be-used Unicode
		# FIXME: This doesnt work for the sadistic case of "hello """, "world"
		csv = self.gsub( /("(?:[^",]|"")+),/, '\\1⥸' )
		csv.split(/\s*,\s*/).map do |str|
			# Put real commas back, unquote, undouble internal quotes
			str[/^".*"$/] ? str[1..-2].gsub('⥸',',').gsub('""','"') : str
		end
	end
end

class DocuBot::MetaSection
	META_SEPARATOR = /^\+\+\+\s*$/ # Sort of like +++ATH0
	NIL_CASTABLE   = nil.extend( Castable )
	attr_reader :__contents__	
	
	def initialize( attrs={}, file_path=nil )
		@attrs = {}
		attrs.each{ |key,value| self[key]=value }
		if file_path && File.exists?( file_path )
			parts = IO.read( file_path, encoding:'utf-8' ).split( META_SEPARATOR, 2 )
			if parts.length > 1
				parts.first.scan(/.+/) do |line|
					next if line =~ /^\s*#/
					next unless line.include?(':')
					attribute, value = line.split(':',2).map{ |str| str.strip }
					self[attribute] = value
				end
			end
			@__contents__ = parts.last && parts.last.strip
		end
	end
	
	def has_key?( key )
		@attrs.has_key?( key )
	end
	
	def []( attribute )
		@attrs.has_key?( attribute ) ? @attrs[attribute] : NIL_CASTABLE
	end
	
	def []=( attribute, value )
		@attrs[attribute.to_s] = value.extend(Castable)
	end
	
	def method_missing( method, *args )
		key=method.to_s
		case key[-1..-1] # the last character of the method name
			when '=' then self[key[0..-2]] = args.first
			else self[key]
		end
	end
	
end

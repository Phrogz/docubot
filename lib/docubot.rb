module DocuBot
	VERSION = '0.0.1'
	DIR     = File.dirname( __FILE__ )
	def self.name( file_path )
		no_extension = File.basename( file_path ).sub( /\.[^.]+$/, '' )
		no_ordering  = no_extension.sub( /^\d*\s/, '' )
	end
end
require 'docubot/converter'
require 'docubot/section'
require 'docubot/page'
require 'docubot/template'
require 'docubot/snippet'
require 'docubot/generator'

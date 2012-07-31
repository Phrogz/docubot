# encoding: UTF-8
# Assume all files read in are UTF-8 format
if Object.const_defined? "Encoding"
	Encoding.default_external = Encoding.default_internal = 'UTF-8'
end

# Wicked monkey patch to avoid File.join verbosity everywhere
class String
	def / ( other )
		File.join( self, other )
	end
end

require 'fileutils'

module FileUtils
	def self.win_path( path )
		path.gsub( '/', '\\' )
	end
end

module DocuBot
	VERSION = '1.0.1'
	DIR     = File.expand_path( File.dirname( __FILE__ ) )
	
	TEMPLATE_DIR = DIR / 'docubot/templates'
	SHELL_DIR    = DIR / 'docubot/shells'
	Dir.chdir( SHELL_DIR ){ SHELLS = Dir['*'] }
	
	def self.id_from_text( text )
		"#" << text.strip.gsub(/[^\w.:-]+/,'-').gsub(/^[^a-z]+|-+$/i,'')
	end
end

require_relative 'docubot/link_tree'
require_relative 'docubot/metasection'
require_relative 'docubot/snippet'
require_relative 'docubot/converter'
require_relative 'docubot/writer'
require_relative 'docubot/page'
require_relative 'docubot/glossary'
require_relative 'docubot/index'
require_relative 'docubot/bundle'

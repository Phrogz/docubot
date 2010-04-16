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
	VERSION = '0.6.1'
	DIR     = File.expand_path( File.dirname( __FILE__ ) )
	
	TEMPLATE_DIR = DIR / 'docubot/templates'
	SHELL_DIR    = DIR / 'docubot/shells'
	Dir.chdir( SHELL_DIR ){ SHELLS = Dir['*'] }
	
	def self.id_from_text( text )
		"#" << text.strip.gsub(/[^\w.:-]+/,'-').gsub(/^[^a-z]+|-+$/i,'')
	end
end

require 'docubot/link_tree'
require 'docubot/metasection'
require 'docubot/snippet'
require 'docubot/converter'
require 'docubot/writer'
require 'docubot/page'
require 'docubot/glossary'
require 'docubot/index'
require 'docubot/bundle'

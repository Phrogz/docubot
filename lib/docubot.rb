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
	VERSION = '0.0.1'
	DIR     = File.dirname( __FILE__ )
	
	TEMPLATE_DIR = File.expand_path( DocuBot::DIR / 'docubot/templates' )
	Dir.chdir TEMPLATE_DIR do
		INSTALLED_TEMPLATES = Dir['*']
	end
	warn "No templates installed in #{TEMPLATE_DIR}!" if INSTALLED_TEMPLATES.empty?
end

require 'docubot/snippet'
require 'docubot/converter'
require 'docubot/writer'
require 'docubot/page'
require 'docubot/glossary'
require 'docubot/bundle'

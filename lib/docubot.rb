# encoding: UTF-8

# Wicked monkey patch to avoid File.join verbosity everywhere
class String
	def / ( other )
		File.join( self, other )
	end
end

class IO
	def self.read_utf8( file )
		File.open( file, 'r:UTF-8' ){ |f| f.read }
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
require 'docubot/page'
require 'docubot/glossary'
require 'docubot/bundle'

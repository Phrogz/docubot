module DocuBot
	VERSION = '0.0.1'
	DIR     = File.dirname( __FILE__ )
	
	TEMPLATE_DIR = File.expand_path( File.join( DocuBot::DIR, 'docubot/templates' ) )
	Dir.chdir TEMPLATE_DIR do
		INSTALLED_TEMPLATES = Dir['*']
	end
	warn "No templates installed in #{TEMPLATE_DIR}!" if INSTALLED_TEMPLATES.empty?
end

require 'docubot/converter'
require 'docubot/page'
require 'docubot/snippet'
require 'docubot/bundle'

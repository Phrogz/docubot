module DocuBot
	TEMPLATE_DIR = File.expand_path( File.join( DocuBot::DIR, 'docubot/templates' ) )
	Dir.chdir TEMPLATE_DIR do
		@available_templates = Dir[ '*' ]
	end
	def self.use_template( template_name )
		@template = template_name
		unless @available_templates.include?( template_name )
			warn "No template named '#{template_name}' exists in #{TEMPLATE_DIR}; using 'default' instead."
			use 'default' unless template_name=='default'
		end
	end
end

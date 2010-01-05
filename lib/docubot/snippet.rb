module DocuBot
	@snippets = {}
	
	def self.handle_snippet( regexp, &handler )
		@snippets[ regexp ] = handler
	end
	
	def self.process_snippets( html )
		@snippets.inject(html){ |html,regexp,handler| html.gsub( regexp, &handler ) }
	end
	
	Dir[ File.join( DocuBot::DIR, 'docubot/snippets/*.rb' ) ].each do |snippet|
		require snippet
	end
	
end


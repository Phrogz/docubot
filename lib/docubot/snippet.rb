module DocuBot
	@snippets = {}
	
	def self.handle_snippet( regexp, &handler )
		@snippets[ regexp ] = handler
	end
	
	def self.process_snippets( html )
		@snippets.inject(html){ |h,(regexp,handler)| h.gsub( regexp, &handler ) }
	end
	
	Dir[ DocuBot::DIR/'docubot/snippets/*.rb' ].each do |snippet|
		require snippet
	end
	
end


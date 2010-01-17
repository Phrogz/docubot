# encoding: UTF-8
module DocuBot
	@snippets = {}
	
	def self.handle_snippet( regexp, &handler )
		@snippets[ regexp ] = handler
	end
	
	def self.process_snippets( page, html )
		# TODO: Don't process snippets on the 'raw' file types
		@snippets.inject(html){ |h,(regexp,handler)| h.gsub( regexp ){ |str| handler[ str, page ] } }
	end
	
	Dir[ DocuBot::DIR/'docubot/snippets/*.rb' ].each do |snippet|
		require snippet
	end
	
end


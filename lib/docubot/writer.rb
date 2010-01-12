# encoding: UTF-8
class DocuBot::Writer
	HAML_OPTIONS = { :format=>:html4, :ugly=>true, :encoding=>'utf-8' }

	@@by_type = {}
	def self.handles_type( type )
		@@by_type[type.to_s.downcase] = self
	end
	def self.by_type
		@@by_type
	end
	DIR = File.expand_path( DocuBot::DIR / 'docubot/writers' )

	def initialize( bundle )
		@bundle = bundle
	end	
end

Dir[ DocuBot::Writer::DIR/'*.rb' ].each do |writer|
	require writer
end

DocuBot::Writer::INSTALLED_WRITERS = DocuBot::Writer.by_type.keys
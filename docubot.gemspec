require 'rubygems'

Gem::Specification.new do |s|
	s.name        = "docubot"
	s.version     = "0.0.1"
	s.date        = "2010-01-05"
	#s.platform    = Gem::Platform::Win32
	s.authors     = ["Gavin Kistner", "Harold Hausman"]
	s.email       = "gavin@phrogz.net"
	s.homepage    = "http://github.com/Phrogz/docubot"
	s.summary     = "Create CHM documentation from a simple hierarchy of text files."
	s.description = s.summary # TODO
	s.files       = %w[ bin/* lib/**/* test/**/* ].inject([]){ |all,glob| all+Dir[glob] }
	s.rubyforge_project = 'docubot'
	s.test_files = %w[test/all.rb]
	s.add_dependency 'bluecloth'
	s.add_dependency 'haml'
	s.requirements << "Windows with HTML Help Workshop installed."
	s.requirements << "BlueCloth gem for Markdown conversion."
	s.requirements << "Haml gem for template interpretation."
	#s.has_rdoc = true
end
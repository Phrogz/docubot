# encoding: UTF-8
require 'rubygems'

Gem::Specification.new do |s|
	s.name        = "docubot"
	s.version     = "0.2.3"
	s.date        = "2010-01-15"
	#s.platform    = Gem::Platform::Win32
	s.authors     = ["Gavin Kistner", "Harold Hausman"]
	s.email       = "gavin@phrogz.net"
	s.homepage    = "http://github.com/Phrogz/docubot"
	s.summary     = "Create documentation from a hierarchy of text files."
	s.description = "DocuBot creates HTML or CHM documentation from a hierarchy of files, supporting markups like Markdown, Textile, and Haml."
	s.files       = %w[ bin/* lib/**/* test/**/* ].inject([]){ |all,glob| all+Dir[glob] }
	s.bindir      = 'bin'
	s.executables << 'docubot'
	s.test_files = %w[test/all.rb]
	s.add_dependency 'haml'
	s.add_dependency 'nokogiri'
	s.add_dependency 'bluecloth'
	s.add_dependency 'RedCloth'
	s.requirements << "Windows with HTML Help Workshop installed."
	s.requirements << "Haml gem for template interpretation."
	s.requirements << "Nokogiri gem for parsing HTML after creation (and manipulating)."
	s.requirements << "BlueCloth gem for Markdown conversion."
	s.requirements << "RedCloth gem for Textile conversion."
	#s.has_rdoc = true
end

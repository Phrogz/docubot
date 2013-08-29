# encoding: UTF-8
require 'rubygems'
$: << 'lib'
require 'docubot'

Gem::Specification.new do |s|
	s.name        = "docubot"
	s.version     = DocuBot::VERSION
	#s.platform    = Gem::Platform::Win32
	s.authors     = ["Gavin Kistner", "Harold Hausman"]
	s.email       = "gavin@phrogz.net"
	s.license     = "MIT License"
	s.homepage    = "http://github.com/Phrogz/docubot"
	s.summary     = "Create documentation from a hierarchy of text files."
	s.description = "DocuBot creates HTML or CHM documentation from a hierarchy of files, supporting markups like Markdown, Textile, and Haml."
	s.files       = %w[ bin/* lib/**/* spec/**/* ].inject([]){ |all,glob| all+Dir[glob] }
	s.bindir      = 'bin'
	s.executables << 'docubot'
	s.test_file   = 'spec/_all.rb'
	s.add_dependency 'haml'
	s.add_dependency 'nokogiri'
	s.add_dependency 'kramdown'
	s.add_dependency 'RedCloth'
	s.add_dependency 'minitest'
	s.requirements << "Windows with HTML Help Workshop installed and hhc.exe in the %PATH%."
	s.requirements << "Haml gem for template interpretation."
	s.requirements << "Nokogiri gem for parsing HTML after creation (and manipulating)."
	s.requirements << "kramdown gem for Markdown conversion."
	s.requirements << "RedCloth gem for Textile conversion."
	s.requirements << "MiniTest gem for running specifications."
	#s.has_rdoc = true
end

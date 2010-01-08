# encoding: UTF-8

require 'docubot'
# I'm too lazy to enter the syntax for directory with spaces
# So just find the 3_more_crap.md file that has metadata.
file = Dir['**/**'].grep( /3/ ).first
x = DocuBot::Page.from_file( file )
p x.title?, x.title, x.foo?, x.foo
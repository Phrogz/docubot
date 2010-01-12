# encoding: UTF-8
class DocuBot::Glossary
	attr_accessor :bundle
	def initialize( bundle )
		@entries   = { 'Squirrel on Trampoline'=>'...you do not want to know' }
		@downcased = {}
		@bundle    = bundle
		@missing   = []
	end
	def []=( term, definition )
		@entries[ term ] = definition
		@downcased[ term.downcase ] = term
	end
	def []( term )
		@entries[ @downcased[ term.downcase ] ]
	end
	def each
		@entries.each{ |term,defn| yield term, defn }
	end
	def add_missing_term( term )
	  @missing << term
	end
end
require 'rubygems'
require 'minitest/spec'
require 'docubot'
SAMPLES = File.dirname(__FILE__)/'samples'
MiniTest::Unit.autorun

class MiniTest::Spec
	class << self
		alias_method :__it__, :it
	end
	def self.it desc, &block
		block ||= proc{ skip "(no tests defined)" }
		__it__( desc, &block )
	end
end
$: << File.join( File.dirname(__FILE__), '..' )
$: << File.join( File.dirname(__FILE__), '..', 'lib' )
require 'minitest/spec'
require 'docubot'
SAMPLES = File.dirname(__FILE__)/'samples'
MiniTest::Unit.autorun

#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "CHM Writer default topic" do
	it "should pick the first valid page as the default if not specified" do
		out, err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'titles' )
			@writer = DocuBot::CHMWriter.new( @bundle )
		end
		@writer.default_topic.must_be_kind_of DocuBot::Page
		# The page 'First One' can't be used as a default because it has a space in the file name
		@writer.default_topic.must_equal @bundle.pages.find{ |page| page.title=='Second One' }
	end
	
	it "should use a valid specified default page" do
		out, err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'default_topic' )
			@writer = DocuBot::CHMWriter.new( @bundle )
		end
		@writer.default_topic.must_be_kind_of DocuBot::Page
		@writer.default_topic.must_equal @bundle.pages.find{ |page| page.title=='Awesomesauce' }
	end
	
	it "should warn about an invalid default topic" do
		out, err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'attributes' )
			@writer = DocuBot::CHMWriter.new( @bundle )
		end
		err.must_include "All About Mr. Friggles"  
		@writer.default_topic.must_be_kind_of DocuBot::Page
		@writer.default_topic.must_equal @bundle.pages.find{ |page| page.title=='defaults' }
	end
	
	it "should warn about a default topic with space in the file name" do
		out, err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'default_topic_2' )
			@writer = DocuBot::CHMWriter.new( @bundle )
		end
		err.must_include "Excellence"  
		@writer.default_topic.must_be_kind_of DocuBot::Page
		@writer.default_topic.must_equal @bundle.pages.find{ |page| page.title=='Awesomesauce' }
	end
	
end
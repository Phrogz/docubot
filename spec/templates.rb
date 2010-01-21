#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "Variety Hour" do
	before do
		@bundle = DocuBot::Bundle.new( SAMPLES/'templates' )
		@pages  = Hash[ *@bundle.toc.every_page.map{ |p| [p.title,p] }.flatten ]
	end
	
	it "uses the 'page' template if not specified" do
		@pages.must_include '1*1'
		html = @pages['1*1'].to_html
		html.must_include 'pager'
		html.scan(/<p>/).length.must_equal 1
	end
	
	it "passes the page for use by another specified template" do
		@pages.must_include '1*2'
		html = @pages['1*2'].to_html
		html.must_include 'doubler'
		html.scan(/<p>/).length.must_equal 3
	end
	
	it "can use the 'page' template explicitly" do
		@pages.must_include '2*1'
		html = @pages['2*1'].to_html
		html.must_include 'page'
		html.scan(/<p>/).length.must_equal 2
	end
	
	it "should have templates handle missing attributes" do
		@pages.must_include '2*2'
		html = @pages['2*2'].to_html
		html.must_include 'doubler'
		html.scan(/<p>/).length.must_equal 4
	end
	
	it "can have templates that do not include contents" do
		@pages.must_include 'goaway'
		html = @pages['goaway'].to_html
		html.must_include 'Oops!'
		html.wont_include 'I DO NOT LIKE YOU'
	end
end
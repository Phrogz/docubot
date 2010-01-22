#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "Validating page titles" do
	before do
		@bundle = DocuBot::Bundle.new( SAMPLES/'titles' )
		@toc    = @bundle.toc
	end
	it "knows who its bundle is" do
		@toc.pages.each{ |page| page.bundle.must_equal @bundle }
	end
	it "ignores leading numbers for the titles (unless all numbers)" do
		@toc.pages.each{ |page| page.title.must_match /(?:^\D|^\d+$)/ }
	end
	it "honors pages specifying their title" do
		@toc.pages.find{ |page| page.title =~ /renamed/i  }.must_be_nil
		@toc.pages.find{ |page| page.title == 'Third One' }.wont_be_nil
	end
	it "replaces underscores with spaces in the title" do
		%w[ First Second Third Fourth Fifth ].each_with_index do |name,i|
			@toc.pages[i].title.must_equal "#{name} One"
		end
	end
	it "doesn't change names of files that are all numbers" do
		@toc.pages.find{ |page| page.title == '911' }.wont_be_nil
	end
end

describe "Traversing page hierarchy" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'links' )
		end
	end
	it "should have #every_page returning an array" do
		@bundle.toc.every_page.must_be_kind_of Array
		@bundle.toc.every_page.length.must_equal 6
	end
	it "should allow traversing every page directly" do
		visited = 0
		@bundle.toc.every_page do |page|
			page.must_be_kind_of DocuBot::Page
			visited += 1
		end
		visited.must_equal 6
	end
end

describe "Testing user variables" do
	it "should identify if a variable has been defined"
	it "should inherit variables from the global"
	it "should override variables from the global"
end

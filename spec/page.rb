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
#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "Pages from 'titletest'" do
	before do
		@bundle = DocuBot::Bundle.new( SAMPLES/'titletest' )
		@toc    = @bundle.toc
	end
	it "knows who its bundle is" do
		@toc.pages.each{ |page| page.bundle.must_equal @bundle }
	end
	it "ignores leading numbers for the titles" do
		@toc.pages.each{ |page| page.title.must_match /^\D/ }
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
end
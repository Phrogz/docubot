#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "Validating page titles" do
	before do
		@bundle = DocuBot::Bundle.new( SAMPLES/'titles' )
		@toc    = @bundle.toc
	end
	it "knows who its bundle is" do
		@toc.children.each{ |node| node.page.bundle.must_equal @bundle }
	end
	it "ignores leading numbers for the titles (unless all numbers)" do
		@toc.children.each{ |node| node.page.title.must_match /(?:^\D|^\d+$|^\d+(?:.\d+)+.*$)/ }
	end
	it "honors pages specifying their title" do
		@toc.children.find{ |page| page.title =~ /renamed/i  }.must_be_nil
		@toc.children.find{ |page| page.title == 'Third One' }.wont_be_nil
	end
	it "replaces underscores with spaces in the title" do
		%w[ First Second Third Fourth Fifth ].each_with_index do |name,i|
			@toc.children[i].page.title.must_equal "#{name} One"
		end
	end
	it "doesn't change names of files that are all numbers" do
		@toc.children.find{ |node| node.page.title == '911' }.wont_be_nil
	end
	it "doesn't change names of files that lead with dotted numerics" do
		@toc.children.find{ |node| node.page.title == '6.1 More' }.wont_be_nil
		@toc.children.find{ |node| node.page.title == '6.2 Even More' }.wont_be_nil
	end
end

describe "Traversing page hierarchy" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'links' )
		end
	end
	it "should have #pages returning an array" do
		@bundle.pages.must_be_kind_of Array
		@bundle.pages.length.must_equal 6
	end
	it "every item should be a Page" do
		@bundle.pages.each do |page|
			page.must_be_kind_of DocuBot::Page
		end
	end
end

describe "Page Roots" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'hierarchy' )
		end
	end
	
	it "should not find any missing links creating the bundle" do
		# The bundle uses root in the page templates extensively
		@err.must_be_empty
	end
	
	it "should have an empty root for pages at the root" do
		@bundle.page_by_html_path['main.html'].root.must_equal ""
	end
	
	it "should have a root appropriate to the HTML depth" do
		@bundle.page_by_html_path['1/page.html'].root.must_equal "../"
		@bundle.page_by_html_path['1/index.html'].root.must_equal "../"
		@bundle.page_by_html_path['1/1.1/page.html'].root.must_equal "../../"
		@bundle.page_by_html_path['1/1.1/index.html'].root.must_equal "../../"
		@bundle.page_by_html_path['1/1.1/1.1.1/page.html'].root.must_equal "../../../"
		@bundle.page_by_html_path['1/1.1/1.1.1/index.html'].root.must_equal "../../../"
	end
end

describe "Testing user variables" do
	it "should identify if a variable has been defined"
	it "should inherit variables from the global"
	it "should override variables from the global"
end

#encoding: UTF-8
require_relative '_helper'

# *************************************************************************************************
describe "Simplest Table of Contents" do
	before do
		Dir.chdir SAMPLES/'simplest' do
			@bundle = DocuBot::Bundle.new( '.' )
			@toc    = @bundle.toc
			@files  = Dir['*']
		end
	end
	
	it "knows who its bundle is" do
		@toc.bundle.must_equal @bundle
	end
	
	it "preserves simple names as titles" do
		@toc.children.length.must_equal @files.length
		@files.each do |source_file|
			filename_without_extension = source_file.sub( /\.[^.]+$/, '' )
			@toc.children.find{ |node| node.title==filename_without_extension }.wont_be_nil
		end
	end
	
	it "has no parent or ancestors" do
		@toc.parent.must_be_nil
		@toc.ancestors.must_be_empty
	end
	
	it "is not the parent of any top-level links" do
		@toc.children.each{ |node| node.parent.wont_equal @toc }
	end
	
	it "is at depth 0 with no root" do
		@toc.depth.must_equal 0
	end	
end

# *************************************************************************************************
describe "Renamed Table of Contents" do
	it "honors the title of the root index file" do
		DocuBot::Bundle.new(SAMPLES/'titles').global.title.must_equal "Title Changin'"
	end
end

# *************************************************************************************************
describe "Sub-page Links in the Table of Contents" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new SAMPLES/'attributes'
			@toc = @bundle.toc
		end
	end
	
	it "should find pages by html link" do
		e1 = @toc.find('explicit1.html')
		e1.wont_be_nil
		e1.page.wont_be_nil
		e1.page.file == 'explicit1.haml'
	end
	
	it "should not have entries for hidden pages" do
		@bundle.pages_by_title['hidden'].wont_be_empty
		hidden = @bundle.page_by_html_path['hidden.html']
		hidden.wont_be_nil
		@toc.find('hidden.html').must_be_nil
		@toc.descendants.select{ |node| node.link['hidden.html'] }.must_be_empty
	end
	
	it "should warn about failed TOC requests" do
		# explicit2.haml has an existing ID on the element for "Heading 1",
		# so it can't update the HTML id or the TOC request to match.
		@err.must_include "Oh No No No"
	end
	
	it "should have sub-entries" do
		e2 = @toc.find('explicit2.html')

		e2.children.length.must_equal 4
		
		kid = e2.children[0]
		kid.title.must_equal "Heading 1"
		# No assumptions are made about the generated id.
		kid.page.must_equal e2.page

		kid = e2.children[1]
		kid.title.must_equal "Heading 1.1"
		kid.link.must_equal 'explicit2.html#h1-1'
		kid.page.must_equal e2.page

		kid = e2.children[2]
		kid.title.must_equal "Giggity"
		kid.file.must_equal 'explicit2.html'
		# No assumptions are made about the generated id.
		kid.page.must_equal e2.page

		kid = e2.children[3]
		kid.title.must_equal "Heading 0"
		kid.file.must_equal   'explicit2.html'
		kid.anchor.must_equal 'h0'
		kid.link.must_equal   'explicit2.html#h0'
		kid.page.must_equal e2.page
	end

	it "should work for Markdown headers with mixed casing" do
		e3 = @toc.find('explicit3.html')
		e3.children.length.must_equal 1

		kid = e3.children[0]
		kid.title.must_equal "It's a Heading!"
		kid.file.must_equal 'explicit3.html'
		kid.page.must_equal e3.page
	end
end

# *************************************************************************************************
describe "ToC with Deep Hierarchy" do
	before do
		@bundle = DocuBot::Bundle.new SAMPLES/'hierarchy'
	end
	
	it "should match the expected hierarchy" do
		@bundle.toc[0].page.title.must_equal '1'
		@bundle.toc[0][0].page.title.must_equal '1.1'
		@bundle.toc[0][0][0].page.title.must_equal '1.1.1'
		@bundle.toc[0][0][0][0].page.title.must_equal '1.1.1p'
		@bundle.toc[0][0][1].page.title.must_equal '1.1p'
		@bundle.toc[0][1].page.title.must_equal '1p'
		@bundle.toc[1].page.title.must_equal '2'
		@bundle.toc[1][0].page.title.must_equal '2.1'
		@bundle.toc[1][0][0].page.title.must_equal '2.1.1'
		@bundle.toc[1][0][0][0].page.title.must_equal '2.1.1p'
		@bundle.toc[1][0][1].page.title.must_equal '2.1p'
		@bundle.toc[1][1].page.title.must_equal '2p'
		@bundle.toc[2].page.title.must_equal 'main'
	end
end


# *************************************************************************************************
describe "ToC with Ordered Items" do
	before do
		@bundle = DocuBot::Bundle.new SAMPLES/'ordering'
	end
	
	it "should match the expected hierarchy" do
		@bundle.toc[0].page.title.must_equal 'License'
		@bundle.toc[1].page.title.must_equal 'Introduction'
		@bundle.toc[2].page.title.must_equal 'Moar'
		@bundle.toc[3].page.title.must_equal 'Three'
		@bundle.toc[4].page.title.must_equal 'Four'
		@bundle.toc[5].page.title.must_equal 'Thirty'
		@bundle.toc[6].page.title.must_equal 'Thirty Five'
		@bundle.toc[7].page.title.must_equal 'Forty'
		@bundle.toc[8].page.title.must_equal 'Appendix'
	end
end
#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

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
	
	it "preserves file system ordering" do
		@files.each_with_index do |source_file,i|
			filename_without_extension = source_file.sub( /\.[^.]+$/, '' )
			@toc.children[i].title.must_equal filename_without_extension
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

describe "Renamed Table of Contents" do
	it "honors the title of the root index file" do
		DocuBot::Bundle.new(SAMPLES/'titles').global.title.must_equal "Title Changin'"
	end
end

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
		@err.must_include "Heading 1"
	end
	
	it "should have sub-entries" do
		e2 = @toc.find('explicit2.html')

		e2.children.length.must_equal 3
		
		# The first sub-link is not "Heading 1" because explicit2.haml has an existing ID on that element
		# and so cannot (at this time) change either the HTML id or the TOC request to match.
		# It is ignored.			
		kid = e2.children[0]
		kid.title.must_equal "Heading 1.1"
		kid.link.must_equal 'explicit2.html#h1-1'
		kid.page.must_equal e2.page

		kid = e2.children[1]
		kid.title.must_equal "Giggity"
		kid.file.must_equal 'explicit2.html'
		# No assumptions are made about the generated id.
		kid.page.must_equal e2.page

		kid = e2.children[2]
		kid.title.must_equal "Heading 0"
		kid.file.must_equal   'explicit2.html'
		kid.anchor.must_equal 'h0'
		kid.link.must_equal   'explicit2.html#h0'
		kid.page.must_equal e2.page
	end
end
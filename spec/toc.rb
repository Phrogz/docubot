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
	
	it "responds to queries for undefined attributes" do
		@toc.never_defined_attribute?.must_equal false
		@toc.never_defined_attribute.must_be_nil
	end
	
	it "responds to queries for defined attributes" do
		@toc.title?.must_equal true
		@toc.title.wont_be_nil
	end
	
	it "defaults to the name 'Table of Contents'" do
		@toc.title.must_equal "Table of Contents"
	end
	
	it "preserves simple names as titles" do
		@toc.pages.length.must_equal @files.length
		@files.each do |source_file|
			filename_without_extension = source_file.sub( /\.[^.]+$/, '' )
			@toc.pages.find{ |page| page.title==filename_without_extension }.wont_be_nil
		end
	end
	
	it "preserves file system ordering" do
		@files.each_with_index do |source_file,i|
			filename_without_extension = source_file.sub( /\.[^.]+$/, '' )
			@toc.pages[i].title.must_equal filename_without_extension
		end
	end

	it "has no parent or ancestors" do
		@toc.parent.must_be_nil
		@toc.ancestors.must_be_empty
	end
	
	it "is the parent of all top-level pages" do
		@toc.pages.each{ |page| page.parent.must_equal @toc }
	end
	
	it "is not a leaf" do
		@toc.leaf?.must_equal false
	end

	it "is at depth 0 with no root" do
		@toc.depth.must_equal 0
		@toc.root.must_equal ""
	end
	
	it "raises an error setting a non-standard attribute" do
		proc{ @toc.title = "Yo!" }.must_raise(NoMethodError)
	end
end

describe "Renamed Table of Contents" do
	it "honors the title of the root index file" do
		DocuBot::Bundle.new(SAMPLES/'titletest').toc.title.must_equal "Title Changin'"
	end
end
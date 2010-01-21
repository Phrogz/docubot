#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "AbusedBundle" do
	it 'requires a valid path' do
		proc{ DocuBot::Bundle.new }.must_raise(ArgumentError)
		proc{ DocuBot::Bundle.new "does not exist" }.must_raise(RuntimeError)
		DocuBot::Bundle.new(SAMPLES/'empty').wont_be_nil
	end
end

describe "Bundle from empty directory" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new SAMPLES/'empty'
		end
	end
	
	it "should have an empty TOC" do
		@bundle.toc.wont_be_nil
		@bundle.toc.pages.must_be_empty
	end
	
	it "should have an empty index" do
	  @bundle.index.wont_be_nil
		@bundle.index.entries.must_be_empty
	end

	it "should have an empty glossary" do
	  @bundle.glossary.wont_be_nil
		@bundle.glossary.entries.must_be_empty
	end
	
	it "should have an empty external link list" do
		@bundle.external_links.wont_be_nil
		@bundle.external_links.must_be_empty
	end
	
	it "should have an empty internal link list" do
		@bundle.internal_links.wont_be_nil
		@bundle.internal_links.must_be_empty
	end
	
	it "should have an empty file link list" do
		@bundle.file_links.wont_be_nil
		@bundle.file_links.must_be_empty
	end
	
	it "should have an empty broken link list" do
		@bundle.broken_links.wont_be_nil
		@bundle.broken_links.must_be_empty
	end
	
	it "should produce no warnings" do
		@err.must_be_empty
	end
	
end


describe "Gathering links" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new SAMPLES/'links'
		end
	end
	
	it "should have link collections be pages hashed to arrays of strings" do
		%w[ external_links internal_links file_links broken_links ].each do |method|
			collection = @bundle.send(method)
			collection.must_be_kind_of Hash
			collection.keys.each do |key|
				key.must_be_kind_of DocuBot::Page
			end
			collection.values.each do |value|
				value.must_be_kind_of Array
				value.each do |item|
					item.must_be_kind_of String
				end
			end
		end
	end
	
	it "should identify (but not validate) external links" do
		known_external = %w[ http://www.google.com/ http://phrogz.net http://phrogz.net/tmp/gkhead.jpg HTTP://NONEXISTENT.SITE ]
		all_external = @bundle.external_links.values.flatten
		known_external.each do |link|
			all_external.must_include link
		end
	end
	
	it "should identify and warn about broken internal links" do
		known_broken = %w[
			fork.html sub1.html root.md sub1/inner1.md
			inner2.html ../sub1 sub1/inner1.md
			../index.html ../sub1 ../index.md
			sub2/GORKBO.bin
		]
		all_broken = @bundle.broken_links.values.flatten
		known_broken.each do |link|
			all_broken.must_include link
			@err.must_include link
		end		
	end
	
	it "should identify valid links to pages or sections" do
		known_internal = %w[
			sub1/inner1.html sub2.html sub2/inner2.html sub1/../sub2/inner2.html
			../root.html inner1.html ../sub2.html ../sub2/inner2.html
			../sub1/index.html index.html
		]
		all_internal = @bundle.internal_links.values.flatten
		known_internal.each do |link|
			all_internal.must_include link
		end		
	end
	
	it "should identify valid links to internal files" do
		known_file_links = %w[ ../sub2/bozo.bin bozo.bin sub2/bozo.bin ]
		all_file_links = @bundle.file_links.values.flatten
		known_file_links.each do |link|
			all_file_links.must_include link
		end		
	end
	
	it "should identify and warn about invalid sub-page anchors" do
		known_broken = %w[ #GORKBO ../root.html#GORKBO ]
		all_broken = @bundle.broken_links.values.flatten
		known_broken.each do |link|
			all_broken.must_include link
			@err.must_include link
		end		
	end

	it "should identify valid sub-page anchors" do
		known_internal = %w[ #sub-id root.html#sub-id ../root.html#sub-id ]
		all_internal = @bundle.internal_links.values.flatten
		known_internal.each do |link|
			all_internal.must_include link
		end		
	end
end

describe "Identifying Conflicts" do
	it "should error when multiple pages will write to the same html" do
		proc{
			@bundle = DocuBot::Bundle.new( SAMPLES/'collisions' )
		}.must_raise(DocuBot::Bundle::PageCollision)
		
		begin
			@bundle = DocuBot::Bundle.new( SAMPLES/'collisions' )
		rescue DocuBot::Bundle::PageCollision => e
			e.message.must_include "page1.md"
			e.message.must_include "page1.textile"
			e.message.must_include "Page 1 (from Markdown)"
			e.message.must_include "Page 1 (from Textile)"
			e.message.must_include "page2.html"
			e.message.must_include "page2.txt"
			e.message.must_include "page2.haml"
			e.message.must_include "Page 2 (from html)"
			e.message.must_include "Page 2 (from text)"
			e.message.must_include "Page 2 (from haml)"
			e.message.wont_include "page3.md"
			e.message.wont_include "page3.bin"
			e.message.wont_include "Page 3"
		end
		
	end
end

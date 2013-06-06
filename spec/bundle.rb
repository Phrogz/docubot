#encoding: UTF-8
require_relative '_helper'

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
		@bundle.toc.descendants.must_be_empty
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
		known_internal << "one two three.html"
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

	it "should identify valid links to internal files at the root" do
		@bundle = DocuBot::Bundle.new SAMPLES/'hierarchy'
		known_file_links = %w[ main.css ../main.css ../../main.css ../../../main.css ]
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
	it "should raise when multiple pages will write to the same html" do
		proc{
			@bundle = DocuBot::Bundle.new( SAMPLES/'collisions' )
		}.must_raise(DocuBot::Bundle::PageCollision)
	end
	
	it "should include the title and filename of every conflicting page" do
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

describe "Bundle with Extra Files" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'files' )
		end
	end
	
	it "should keep track of extra files seen" do
		@bundle.extras.wont_be_nil
		static_files = %w[ common.css _static/foo.png section/foo.jpg ]
		static_files << "section/sub section/foo.gif"
		static_files.each do |path|
			@bundle.extras.must_include path
		end
	end
	
	it "should not count page sources as extra files" do
		page_files = %w[ index.md another.md first.textile section/page.haml ]
		page_files << "section/sub section/page.txt"
		page_files.each do |path|
			@bundle.extras.wont_include path
		end
	end
	
	it "should skip files specified by global glob matches" do
		@bundle.global.ignore.as_list.must_equal %w[ **/*.psd **/*.ai **/Thumbs.db BUILDING.txt ]
		bad_files = %w[ _static/foo.ai _static/foo.psd _static/Thumbs.db ]
		bad_files << "section/sub section/Thumbs.db"
		bad_files.each do |path|
			@bundle.extras.wont_include path
		end
	end
	
	it "should not count ignored files as the source for pages" do
		@bundle.pages.find{ |page| page.file == 'BUILDING.txt' }.must_be_nil
		@bundle.page_by_file_path['BUILDING.txt'].must_be_nil
	end
end

describe "Bundle with Skipped Files" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new( SAMPLES/'underscores' )
		end
	end
	
	it "should not include files that start with an underscore" do
		titles = @bundle.pages.map(&:title)
		titles.wont_include "ignoreme"
		titles.wont_include "andignoreme"
		titles.wont_include " ignoreme"
		titles.wont_include " andignoreme"
	end
	
	it "should not include folders inside _static" do
		titles = @bundle.pages.map(&:title)
		titles.wont_include "Foo"
		titles.wont_include " Foo"
		titles.wont_include "Bar"
		titles.wont_include " Bar"
	end
	
end

describe "Pages in bundles" do
	before do
		@titles = [ 'First One', 'Second One', 'Third One', 'Fourth One', 'Fifth One', '911' ]
		Dir.chdir SAMPLES/'links' do
			@files = Dir['**/*'] - %w[ index.txt sub2/bozo.bin pending.md ]
			@htmls = @files.map{ |path|
				path[/\.[^.]+$/] ? path.gsub(/\.[^.]+$/,'.html') : path/'index.html'
			}
		end
		@out, @err = capture_io do
			@titles_bundle = DocuBot::Bundle.new SAMPLES/'titles'
			@links_bundle  = DocuBot::Bundle.new SAMPLES/'links'
		end
	end
	
	it "should allow you to find arrays of pages by title" do
		@titles_bundle.pages_by_title.wont_be_nil
		@titles.each do |page_title|
			pages = @titles_bundle.pages_by_title[page_title]
			pages.must_be_kind_of Array
			pages.length.must_equal 1
			pages.first.must_be_kind_of DocuBot::Page
		end
	end
	
	it "should return an empty array for a non-existent page" do
		pages = @titles_bundle.pages_by_title['NONE SUCH']
		pages.must_be_kind_of Array
		pages.length.must_equal 0
	end

	it "should not include the main index file in the titles" do
		pages = @titles_bundle.pages_by_title["Title Changin'"]
		pages.must_be_kind_of Array
		pages.length.must_equal 0
	end
	
	it "should give access to pages by source file path" do
		@links_bundle.page_by_file_path.wont_be_nil
		@files.each do |path|
			@links_bundle.page_by_file_path[path].must_be_kind_of DocuBot::Page
		end
	end
	
	it "should return nil for an unfound file path" do
		@links_bundle.page_by_file_path['NONE SUCH'].must_be_nil
	end
	
	it "should not include raw files in the file paths" do
		@links_bundle.page_by_file_path['sub2/bozo.bin'].must_be_nil
	end
	
	it "should give access to pages by html file path" do
		@links_bundle.page_by_html_path.wont_be_nil
		@htmls.each do |path|
			p path unless @links_bundle.page_by_html_path[path]
			@links_bundle.page_by_html_path[path].wont_be_nil
			@links_bundle.page_by_html_path[path].must_be_kind_of DocuBot::Page
		end
	end
	
	it "should return nil for an unfound html path" do
		@links_bundle.page_by_html_path['NONE SUCH'].must_be_nil
	end
	
	it "should not include raw files in the html paths" do
		@links_bundle.page_by_html_path['sub2/bozo.bin'].must_be_nil
	end

	it "should not include raw files in the html paths" do
		@links_bundle.page_by_html_path['sub2/bozo.bin'].must_be_nil
	end

	it "should not include pages marked as ready:false" do
		@links_bundle.page_by_file_path["pending.md"].must_be_nil
	end

end

describe "Global bundle attributes" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new SAMPLES/'attributes'
		end
	end
	
	it "should have a global object" do
		@bundle.global.wont_be_nil
	end
	
	it "should be indexable by method and return strings" do
		@bundle.global.author.must_equal  "Gavin Kistner"
		@bundle.global.default.must_equal "All About Mr. Friggles"
		@bundle.global.quotes.must_equal  %q{"It's all about Mr. Benjamin", "I have never seen this cat before in my life!"}
		@bundle.global.awesome.must_equal "true"
	end
	
	it "should be indexable by string" do
		@bundle.global['author.email'].must_equal "!@phrogz.net"
		@bundle.global['author website'].must_equal "http://phrogz.net"
	end
	
	it "should use utf8 for the strings" do
		if Object.const_defined? :Encoding
			Encoding.compatible?( @bundle.global.title, "UTF-8™")
		end
		@bundle.global.title.must_equal "Friggles® The Cat, ©2009"
	end
	
	it "should allow casting values to boolean" do
		@bundle.global.awesome.as_boolean.must_equal true
	end

	it "should allow casting values to arrays of strings" do
		quotes = @bundle.global.quotes.as_list
		quotes.must_be_kind_of Array
		quotes.must_equal [ "It's all about Mr. Benjamin", "I have never seen this cat before in my life!" ]
	end
end

describe "Page attributes" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new SAMPLES/'attributes'
		end
	end
	
end
#encoding: UTF-8
require_relative '_helper'

describe "Applying syntax highlighting" do
	before do
		@bundle = DocuBot::Bundle.new SAMPLES/'highlighting'
	end
	
	it "should highlight code in HTML" do
		doc = @bundle.pages.find{ |p| p.meta.title=="Highlighting HTML" }.nokodoc
		cpp_class = doc.at_css('pre.language-cpp span.class')
		cpp_class.wont_be_nil
		cpp_class.text.must_equal "CUBE_Plugin"

		ruby_key = doc.at_css('code.language-ruby span.keyword')
		ruby_key.wont_be_nil
		ruby_key.text.must_equal "def"
	end

	it "should highlight code in Markdown" do
		doc = @bundle.pages.find{ |p| p.meta.title=="Highlighting Markdown" }.nokodoc
		cpp_class = doc.at_css('pre span.class')
		cpp_class.wont_be_nil
		cpp_class.text.must_equal "CUBE_Plugin"

		ruby_key = doc.at_css('code.language-ruby span.keyword')
		ruby_key.wont_be_nil
		ruby_key.text.must_equal "def"
	end

	it "should not highlight code without a matching class" do
		%w[ HTML Markdown ].each do |title|
			doc = @bundle.pages.find{ |p| p.meta.title=="Highlighting #{title}" }.nokodoc
			no_touch = doc.at_css('#untouched1')
			no_touch.wont_be_nil
			no_touch.inner_html.must_equal "def call; end"
		end
	end

	it "should not highlight if turned off" do
		%w[ HTML Markdown ].each do |title|
			doc = @bundle.pages.find{ |p| p.meta.title=="Highlighting No #{title}" }.nokodoc
			cpp_class = doc.at_css('pre.language-cpp span.class')
			cpp_class.must_be_nil

			ruby_key = doc.at_css('code.language-ruby span.keyword')
			ruby_key.must_be_nil
		end
	end

end
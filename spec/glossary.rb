#encoding: UTF-8
require File.join(File.dirname(__FILE__), "_helper")

describe "Glossary Scanner" do
	before do
		@public_terms = [ "Simple Term", "Complex Term" ]
		@hidden_terms = [ "Secret Term"]
		@all_terms = @public_terms + @hidden_terms
		@expected_paragraphs = {
			"Simple Term"  => 2,
			"Complex Term" => 3
		}
		@out, @err = capture_io do
			@bundle   = DocuBot::Bundle.new SAMPLES/'glossary'
			@glossary = @bundle.glossary
			@page     = @bundle.toc.every_page.find{ |page| page.title=='Glossary' }
			@fulldoc  = Nokogiri::HTML( @page.to_html )
		end
	end
	
	# No _glossary folder handled in the Bundle spec for empty site
	
	it "should have one internal entry for each term defined in _glossary" do
		@glossary.entries.size.must_equal @all_terms.length
	end

	it "should honor page titles as terms" do
		@all_terms.each do |term|
			@glossary.entries[term].wont_be_nil
		end
	end
	
	it "uses DocuBot::Page instances for the definitions" do
		@glossary.entries.values.each do |defn|
			defn.must_be_kind_of DocuBot::Page
		end
		@glossary.entries["Secret Term"].hide.must_equal true
	end

	it "supports iterating over the entries with each" do
		count = 0
		@glossary.each do |page,defn|
			page.must_be_kind_of String
			defn.must_be_kind_of DocuBot::Page
			count += 1
		end
		count.must_equal @all_terms.length
	end
	
	
	it "uses converters for page content" do
		@expected_paragraphs.each do |term,paras|
			@glossary.entries[term].nokodoc.xpath('//p').length.must_equal paras
		end
	end
	
	it "supports a glossary template that generates HTML for terms" do
		definitions = @fulldoc.xpath('//dt')
		@expected_paragraphs.each do |term,paras|
			dt = definitions.find{ |node| node.inner_text==term }
			dt.wont_be_nil
			dt.next_element.xpath('.//p').length.must_equal paras			
		end
	end

	it "does not include hidden pages in the output" do
		definitions = @fulldoc.xpath('//dt')
		@hidden_terms.each do |term|
			@fulldoc.at_xpath("//dt[text()='#{term}']").must_be_nil
		end
	end
end

describe "Glossary Snippet" do
	before do
		@out, @err = capture_io do
			@bundle   = DocuBot::Bundle.new SAMPLES/'glossary'
			@glossary = @bundle.glossary
		end
	end
	
	it "should know about missing terms" do
		@glossary.missing_terms.must_include "crazy term"
	end
	
	it "should not mistake alternate text for a missing term" do
		@glossary.missing_terms.wont_include "more complex term"
	end
	
	it "should warn about missing terms" do
		@err.must_include "crazy term"
	end
end
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
		@bundle = DocuBot::Bundle.new SAMPLES/'empty'
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
end

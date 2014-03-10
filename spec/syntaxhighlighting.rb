#encoding: UTF-8
require_relative '_helper'

describe "Applying syntax highlighting" do
	before do
		@out, @err = capture_io do
			@bundle = DocuBot::Bundle.new SAMPLES/'highlighting'
		end
	end
	
	it "should highlight code blocks" do
		puts @bundle.pages.first.nokodoc
	end
end
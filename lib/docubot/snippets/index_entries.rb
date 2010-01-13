# encoding: UTF-8
pattern = /@@(\w[\w ]*?)@@/
DocuBot.handle_snippet pattern do |match, page|
	keyword = match[ 2..-3 ]
	page.bundle.index.add( keyword, page )
	keyword
end
# encoding: UTF-8
pattern = /\$\$(\w[\w: ]*\w)\$\$/
DocuBot.handle_snippet pattern do |match, page|
  parts = match[ 2..-3 ].split(':',2)
  text, term = parts.first, parts.last
	page.bundle.glossary.term_used( term, page )
	"<span class='glossary' term='#{term}'>#{text}</span>"
end
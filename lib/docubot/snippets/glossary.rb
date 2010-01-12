# encoding: UTF-8
pattern = /\$\$(\w[\w ]*\w)\$\$/
DocuBot.handle_snippet pattern do |match, page|
  term = match[ 2..-3 ]
  if page.bundle.glossary[ term ]
  	"<span class='glossary'>#{term}</span>"
  else
    page.bundle.glossary.add_missing_term( term )
  	"<span class='missing'>#{term}</span>"
  end
end
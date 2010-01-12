# encoding: UTF-8
pattern = /\$\$(\w[\w: ]*\w)\$\$/
DocuBot.handle_snippet pattern do |match, page|
  parts = match[ 2..-3 ].split(':',2)
  text, term = parts.first, parts.last
  if page.bundle.glossary[ term ]
  	"<span class='glossary'>#{text}</span>"
  else
    page.bundle.glossary.add_missing_term( term )
  	"<span class='missing'>#{text}</span>"
  end
end
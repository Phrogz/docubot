pattern = /\$\$(\w[\w ]*\w)\$\$/
DocuBot.handle_snippet pattern do |match|
	term = match[pattern,1]
	# TODO: look up glossary terms, include information
	"<span class='glossary'>#{term}</span>"
end
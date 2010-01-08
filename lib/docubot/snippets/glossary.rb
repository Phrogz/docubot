# encoding: UTF-8
pattern = /\$\$(\w[\w ]*\w)\$\$/
DocuBot.handle_snippet pattern do |match|
	# TODO: look up glossary terms, include information
	"<span class='glossary'>#{match[ 2..-3 ]}</span>"
end
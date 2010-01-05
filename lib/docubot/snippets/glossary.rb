DocuBot.handle_snippet /\$\$(\w[\w ]*\w)\$\$/ do
	# TODO: look up glossary terms
	"<span class='glossary'>#{$1}</span>"
end
#encoding: UTF-8
require_relative '_helper'

# http://www.w3.org/TR/html4/types.html#type-id
# We disallow colons or periods in the ID because they mess up CSS selectors
# We require an octothorpe at the front because it makes life easier
VALID_ID = /#[a-z][\w-]*/i

describe "Generating IDs from Text" do
	it "must create a valid identifier from a variety of input" do
		DocuBot.id_from_text("foo").must_match VALID_ID
		DocuBot.id_from_text("foo-bar").must_match VALID_ID
		DocuBot.id_from_text("Foo-Bar").must_match VALID_ID
		DocuBot.id_from_text("foo bar").must_match VALID_ID
		DocuBot.id_from_text(" foo").must_match VALID_ID
		DocuBot.id_from_text("foo ").must_match VALID_ID
		DocuBot.id_from_text(" foo ").must_match VALID_ID
		DocuBot.id_from_text("foo:bar").must_match VALID_ID
		DocuBot.id_from_text("foo.bar").must_match VALID_ID
		DocuBot.id_from_text("foo!bar").must_match VALID_ID
		DocuBot.id_from_text("foo?!bar").must_match VALID_ID
		DocuBot.id_from_text("foo(bar)").must_match VALID_ID
		DocuBot.id_from_text("(foo)bar").must_match VALID_ID
		DocuBot.id_from_text("!foo bar").must_match VALID_ID
		DocuBot.id_from_text("foo: bar").must_match VALID_ID
		DocuBot.id_from_text("!!!").wont_match VALID_ID
	end
end
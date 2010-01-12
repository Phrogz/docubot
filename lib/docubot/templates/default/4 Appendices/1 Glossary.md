flavor: glossary
+++
The metadata section in this file instructs this page to use the `glossary.haml` partial. That partial has the logic needed to spit out information from the glossary (gathered from a `_glossary` directory and/or `$$terms in double dollars$$` sprinkled throughout the documentation).

The `glossary.haml` partial chooses to ignore the contents of the page calling it (i.e. this text) so this will never actually see the light of day.
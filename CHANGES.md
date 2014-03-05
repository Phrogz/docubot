# 1.1.3 : 2014-March-5
* Add `-v` or `--version` for command line.

----

# 1.1.2 : 2013-August-29
* Treat `mailto:` href as unvalidated external links (fixes issue #25).
* Added explicit MIT License.

----

# 1.1.1 : 2013-August-28
* Fix sorting of files to use numeric ordering instead of lexicographic ordering _(e.g. `2_Foo.txt` comes before `03_Bar.txt`)_.

----

# 1.1 : 2013-June-6
* Add `skip:true` option to fully skip pages based on meta information.

----

# 1.0.2 : 2013-May-22
* Markdown conversion of code blocks turns off line numbers when syntax highlighting is enabled.

----

# 1.0.1 : 2012-July-31
* Fix problems with Table of Contents linking to files/folders with an ampersand in the name.

----

# 1.0.0 : 2012-July-31
* Requires Ruby 1.9.2+
* All files are explicitly read as UTF-8
* Searching for a TOC entry by text now works if the element already has an ID, or needs one generated
* Using [kramdown](http://kramdown.rubyforge.org/) (and its auto-id generation) works with TOC entries specified by text  
  _(Apostrophes and quotes are now ignored; elements are found by text value instead of assumed id.)_
* Fixed CHM writer to work standalone (outside of the bin/docubot command)
  * _TODO: provide a mechanism to control writer options other than assumed global `ARGS`._
* Changed to use `require_relative`; requires Ruby 1.9.2+  
  _(Major version number bump due solely to this; all other features are backwards compatible.)_

----

# 0.7.1 : 2012-June-25
* Fixed bug where directories inside _static created TOC entries.
  [Issue #24](https://github.com/Phrogz/docubot/issues/24)

----

# 0.7.0 : 2012-May-24
* Switched to using [kramdown](http://kramdown.rubyforge.org/) instead of BlueCloth for Markdown conversion
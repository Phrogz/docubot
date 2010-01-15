# Organizing the Project
The names and structure of files and folders are used for the table of contents.
The only exceptions are:

* As seen here, leading digits (used to sort items) are removed from the titles.
* Also as seen here, underscores in the name are replaced with spaces.
* Specifying a `title` attribute in the metasection overrides the file/folder name.
* Files may be hidden from the contents by putting `hide: true` in the metasection.
* A few special folders at the root of the project--`_glossary`, `_static`, and
  `_templates`--are exempt from conversion and the table of contents.

# Creating Project Files
The file extension of files in the project folder controls the interpretation of the
markup. There are currently are five converters (of varying usefulness) which may be
used to convert your markup to HTML:

1. **[Markdown](http://daringfireball.net/projects/markdown/syntax)** (*.md):
   This is the simplest (useful) markup converter. It has the benefits of being
   easy to read and sensible to author with almost no knowledge of HTML.
   
   The downside is that there is very little semantic markup available beyond
   headings and lists. You can inject inline HTML as you wish, however.

2. **[Textile](http://redcloth.org/textile)** (*.rc, *.textile): 
   Textile has a lot of nice formatting features not present in Markdown.
   Further, it provides a much tighter coupling with HTML, allowing you to express
   a lot of HTML concepts in a markup format slightly better than HTML.
   
   It's better than HTML, but not as much fun to write in.

3. **HTML** (*.html, *.htm):
   This 'converter' just passes the HTML through untouched.
   (We plan on adding some sanitization options.)

4. **Raw Code** (*.rb, *.c, *.h, *.cpp, *.cs, *.txt, *.raw):
   Files with any of the above extensions will be wrapped in an HTML `<pre>` tag
	 and sent along as the content of the page.

5. **[Haml](http://haml-lang.com/docs.html)** (*.haml):
   Haml is the language that all the templates of DocuBot are written in.
   It's a super-elegant, minimalist way of expressing HTML structure, merging
   in Ruby code where you see fit.
   
   It also lets you drop into Markup, Textile, or a variety of other
   [filters](http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#filters)
   for any section.
   
   Haml is useful for pages where you need a lot of specific HTML structure.
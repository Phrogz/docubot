# About DocuBot
DocuBot is a simple tool for easily creating complex CHM documents from a hierarchy of plain text files. At its simplest:

1. Create a directory hierarchy of text files with the extension .md.
   * This will use [Markdown][1] to convert the files to HTML.
   * Use `docubot create mydirectory` to create a helpful shell for you.

2. Run `docubot mydirectory`
   * DocuBot will create `mydirectory.chm` in short order.
     The CHM will have Table of Contents based on the names of the directories and files.


# Requirements
DocuBot requires [Ruby][2] and Windows. (Windows is required to create the CHM file using Microsoft's (proprietary) [HTML Help Workshop][3].)


# Installing
1. Ensure you're running RubyGems 1.3.5 or newer:
   * `gem update --system`
2. Install the DocuBot gem:
   * `gem install docubot --no-rdoc --no-ri`
     * _Disabling system documentation is necessary because the RedCloth used by DocuBot currently has issues when installing on Windows._
     * This will install the `docubot` binary as well as all necessary supporting files.
3. Download and install [Microsoft HTML Help](http://msdn.microsoft.com/en-us/library/ms669985.aspx).
4. Ensure that the HTML Help Compiler executable (`hhc.exe`) is in your PATH.


# Additional Control

## Sorting the Table of Contents
Files and directories may be named starting with numbers to control the sort order, such as:

    1 Introduction
      1 License Agreement.md
      2 About our Software.md
    2 Basics
      1 Getting Started.md
      2 Interface Overview.md
    3 Appendix

These numbers will not appear in the titles for the sections and pages.


## Using Custom Page Titles
Some characters cannot be used in file names on Windows, such as `/ ? < > \ : * | "`. If you want to name a page using these characters, you need to specify the title in a metadata section at the top of the file.

The metadata section consists of lower-case attributes (like "`title`") and values separated by colons. This section must be separated from the rest of the document by three plus characters on their own line ("`+++`"). For example:

    title   : What does the Metadata Section Look Like?
    author  : Gavin Kistner
    edited  : 2010-01-05
    summary : Example of a file using a metadata section.
    +++
    It does not matter what this file is named; the title above will be
    used instead. (However, the file name affects sorting in the TOC.)
    
    See the section "Using Additional Metadata" in the DocuBot help for
    more information on using other fields in the metadata section.


## Using Custom Section Titles
A file named "index.md" inside a directory describes the section itself. Such a file with a title attribute in the metadata section allows you to set the title of the section itself.

Note that for the metadata section to be recognized, the section must end with `+++` on its own line (even if you have no additional content you wanted to write for that section).


## Adding Terms to the Index
1. By default, every heading (`<h1>`-`<h6>`) and definition term (`<dt>`) in your final pages will add an entry in the index to the page using it.
   * _If you don't want headings and/or definitions indexed for a particular page, mention one or both of them at the top of the page like this: `no-index: headings, definitions`._
	
2. Additionally, putting something like `keywords: Introduction, Overview, Tool Panel` at the top of the page will add index entries for those terms.

3. Additionally, placing double 'at' characters around text on your page, such as "`When using the @@hyperwrench@@, be sure...`", adds index entries for each word or phrase you wrap.


## Adding Glossary Entries
If you create a folder named `_glossary` at the root of your project, any pages you put in there will be added to the general glossary with the title of the page (filename or `title` attribute) as the term and the contents of the page as the definition.

To use the glossary page in your site, create a page wherever you want with `template: glossary` in the metasection at the top. The glossary of terms and definitions will be generated from the glossary template.

To reference a glossary term on a particular page, put two dollar signs around the term, like `If the wrench starts $$fonkulating$$, run as fast...`. If you are using the `glossary.js`, generated `glossary-terms.js`, and `glossary.css` you will get a little tooltip with the definition when you click on it.

If you want to create a glossary link using slightly different text than the glossary term, do it like so this, `With many $$rigid bodies:rigid body$$ in the scene, ...`. That will display the text "rigid bodies" but link it to the glossary term "rigid body".


## Adding Sub-Heading Links to the Table of Contents
If you have a single page with many sections on it and you want to see sub-links for those sections in the table of contents, you can accomplish it in one of two ways.

If you have content with explicit `id` attributes on various HTML elements, add a `toc` entry in the metasection with a **space-delimited** list of the element identifiers whose contents you want added as a sub-link in the table of contents. For example:

    title: Welcome to FrobozzCo
    toc  : intro learning
    +++
    <h2 id="intro">Introduction</h2>
    ...
    <h3 id="goaway">But Don't Call Us...</h3>
    ...
    <h2 id="learning">Learning from Your Mistakes</h2>

In the above example, the Table of Contents will have the following hierarchy:

    Welcome to FrobozzCo
       Introduction
       Learning from Your Mistakes

The sub-links in the table of contents will link directly to the appropriate subsection.

If you are using markup (such as Markdown) without specifying HTML `id` attributes, do not fret. DocuBot can automatically create identifiers for the following HTML elements: `h1 h2 h3 h4 h5 h6 legend caption dt`. In this scenario, add a `toc` entry in the metasection with a **comma-delimited** list of the exact text for the elements you wish to link to. For example:

    title: Welcome to FrobozzCo
    toc  : Introduction, Learning from Your Mistakes
    +++
    ## Introduction
    ...
    ### But Don't Call Us...
    ...
    ## Learning from Your Mistakes

The results will be the same as above.

_If you want `id` attributes auto-generated for the elements listed above, but don't necessarily need them for custom `toc` sub-entries, use `auto-id: true` to force them to be generated._


## Editing the HTML Templates and Stylesheet
TODO: _See the files in the `_templates` directory (and the `_root` directory inside it). Bone up on your Haml and Ruby skills._

TODO: _Sections default to `section.haml`, pages to `page.haml`. Use `template: foobar` at the top of a page to get it to use another page template. All content finishes by being wrapped in `top.haml`._


## Using Additional Metadata
TODO: _Labeled values in the metasection are available as properties of the `page` object made available to templates. Use `if page.value` to ask if any value has been defined. Use `page['non-standard name']` if the name has spaces or hyphens or other non-standard idenfitiers in it._


## Setting Global Metadata
A file named "index.md" in the root of your documentation directory allows you to set global metadata for the entire project. Attributes defined in this file are available as properties on a `global` object in your template. For example:

    # index.md at the root of your site
    title  : FrobozzCo Reference Manual
    company: Froboz Widgets (a FrobozzCo subsidiary)
    default: Welcome to FrobozzCo
    +++


    # page.haml in your template
    %html
      %head
        ...
      %body
        ...
        #footer
          Copyright ©#{Time.now.year} #{global.company}. All rights reserved.

### CHM-Specific Metadata
A `title` attribute set in a root "index.*" page will be used as the name for the CHM documentation. _(As seen above, the title of the CHM would show as "FrobozzCo Reference Manual".)_

A `default` attribute set in this root file will try to find the page with that exact title and use it as the page displayed when the CHM opens the CHM documentation. _(As seen above, the CHM would open to the "Welcome to FrobozzCo" page, if it exists.)_ Due to a limitation in the CHM `hhp` file format (or DocuBot's understanding of it), the page used as the `default` may not have spaces in the file name.

## Automatic Sections
By default, the contents of every page will have `<div class='section'>...</div>` wrapped around the 'children' of headings. For example, this (flat) HTML content for a page:

    <p>Not sure how to start your day? Let us help!</p>
    
    <h1>1.0 Getting Started</h1>
    <p>Welcome!</p>
    
    <h2>1.1 First Things First</h2>
    <p>Get out of bed.</p>
    
    <h2>1.2 Get Dressed</h2>
    <p>Put on your clothes.</p>
    
    <h3>1.2.1 First, the undergarments</h3>
    <p>...and then the rest</p>
    
    <h1>2.0 Eating Breakfast</h1>
    <p>And so on, and so on...</p>

will actually be transformed into this:

    <p>Not sure how to start your day? Let us help!</p>
    
    <h1>1.0 Getting Started</h1>
    <div class='section'>
       <p>Welcome!</p>
    
       <h2>1.1 First Things First</h2>
       <div class='section'>
          <p>Get out of bed.</p>
       </div>
    
       <h2>1.2 Get Dressed</h2>
       <div class='section'>
          <p>Put on your clothes.</p>
       
          <h3>1.2.1 First, the undergarments</h3>
          <div class='section'>
            <p>...and then the rest</p>
          </div>
       </div>
    </div>
    
    <h1>2.0 Eating Breakfast</h1>
    <div class='section'>
      <p>And so on, and so on...</p>
    </div>

This lets you put CSS such as: `div.section{ margin-left:1em }` to get your page content visually indented.

This code is run on the contents of the page before being wrapped in the page and top templates. Presumably if you want to control the hierarchy in your templates, you can do that yourself.

_If you do not want this transformation applied to a particular page, put `auto-section: false` in the metasection for the page._

## Ignoring Files
Do you have certain files that you want ignored, such as source Photoshop files in your images directory, Thumbs.db files from Windows, or even text files that might be mistaken for pages? If so, add an `ignore` attribute in the metasection on the index.* file at the root of your site. The value of this is a space-delimited list of glob patterns for files and folders to ignore.

For example, to ignore *.psd and *.ai files in any directory, and ignore any README files at the root of your site, you would add:

    title : My Super Documentation
    ignore: **/*.psd **/*.ai README.*
    +++



# Metasection Attribute Reference
Here are all the attributes you can put in the metasection for a page or the site that have special meaning. (Of course, you can put your own attributes in for notes or metadata to be used by your own templates.)

    # Any line in the metasection that starts with an octothorpe (number symbol)
    # will be considered a comment and ignored.
    
    
    #######################################
    # Attributes in the global index.* file
    #######################################
    
    # The title for your entire documentation project. (Shows in the title of CHMs.)
    # Defaults to "Table of Contents"
    title: FrobozzCo Reference Manual
    
    # The page to show when the documentation opens, specified by exact title.
    # Defaults to first page in the Table of Contents.
    default: Welcome to FrobozzCo
    
    # Name of the company (shown in the footer of the default `top.haml`).
    # Defaults to nothing (not shown).
    company: Froboz Widgets (a FrobozzCo subsidiary)
    
    # Glob patterns describing files (including page sources) to ignore.
    # Ignoring a page does more than hide it; it doesn't generate it.
    # Defaults to including every file.
    ignore: **/*.psd **/.DS_Store **/Thumbs.db **/.[^.$]*
    
    
    ###################################
    # Attributes at the top of any page
    ###################################
    
    # The title for this page (or section for an index.* file in a folder).
    # Defaults to the name of the file with underscores made into spaces
    # and leading digits removed.
    title: Welcome to FrobozzCo
    
    # Create one or more entries in the Index pointing to this page.
    keywords: Introduction, Overview, Tool Panel
    
    # Do not create additional Index entries for headings and/or definition titles.
    # Defaults to add both headings and definition titles to the Index.
    no-index: headings definitions
    
    # Do not wrap the 'children' of headers in <div class='section'>...</div>
    # Default: true
    auto-section: false
    
    # Create sub-entries of this page in the Table of Contents, linking to specific
    # HTML elements based on their id attribute. The title of the entry will be the
    # text in the HTML element.
    toc: #intro, #getting.started, #more-information
    
    # Create sub-entries of this page in the Table of Contents, linking to specific
    # HTML elements based on the exact text in the element. This only works for the
    # following HTML elements: <h1>-<h6>, <legend>, <caption>, <dt>
    # Requires two or more elements to be specified, separated by commas.
    toc: "Introduction to FrobozzCo", "Getting Started with Widgets", "For More Info..."
    
    # Generate HTML ids for the following elements: <h1>-<h6>, <legend>, <caption>, <dt>
    # The id created for "<h2>1.2 Awesome & Sauce: more (and stuff)</h2>" will be:
    # <h2 id='Awesome-Sauce:-more-and-stuff'>...
    # Defaults to false unless the toc attribute is trying to link to text.
    auto-id: true
    
    # For pages/sections, hide the item from the Table of Contents (can still link to it).
    # For glossary entries, hide the glossary entry (not even defined on pages).
    # Default: false (show the item)
    hide: true



# Additional Planned Features
* Additional Markups (e.g. RDoc)
* Customizing TOC Icons (via nice names, not just indexes)
* Additional output formats (single-page HTML, single PDF)
* [Doxygen][4] integration
* [Qt Assistant][5]

[1]: http://daringfireball.net/projects/markdown/basics
[2]: http://rubyinstaller.org/
[3]: http://msdn.microsoft.com/en-us/library/ms669985(VS.85).aspx
[4]: http://www.stack.nl/~dimitri/doxygen/
[5]: http://doc.trolltech.com/4.6/assistant-details.html
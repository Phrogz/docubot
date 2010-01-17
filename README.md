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
3. Download and install [Microsoft HTML Help](http://msdn.microsoft.com/en-us/library/ms669985(VS.85).aspx).
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


## Adding terms to the Index
By default, every heading (`<h1>`-`<h6>`) and definition term (`<dt>`) in your final pages will add an entry in the index to the page using it.

Additionally, putting something like `keywords: Introduction, Overview, Tool Panel` at the top of the page will add index entries for those terms.

Additionally, place double 'at' characters around text on your page, like `When using the @@hyperwrench@@, be sure...` to add index entries for each word or phrase you wrap.

If you don't want headings and/or definitions indexed for a particular page, mention one or both of them at the top of the page like this: `no-index: headings, definitions`.


## Adding Glossary Entries
If you create a folder named `_glossary` at the root of your project, any pages you put in there will be added to the general glossary with the title of the page (filename or `title` attribute) as the term and the contents of the page as the definition.

To use the glossary page in your site, create a page wherever you want with `template: glossary` in the metasection at the top. The glossary of terms and definitions will be generatd from the glossary template.

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

## Editing the HTML Templates and Stylesheet
TODO: _See the files in the `_templates` directory (and the `_root` directory inside it). Bone up on your Haml and Ruby skills._

TODO: _Use `template: foobar` at the top of a page to get it to use another page template. (Will always be wrapped in `top.haml`.)_


## Using Additional Metadata
TODO: _Labeled values in the metasection are available as properties of the `page` object made available to templates. Use `page.value?` to ask if any value has been defined. Use page['non-standard name'] if the name has spaces or hyphens or other non-standard idenfitiers in it._


## Setting Global Metadata
A file named "index.md" in the root of your documentation directory allows you to set global metadata for the entire project. Attributes defined in this file are available as properties on a `global` object in your template. For example:

    # index.md at the root of your site
    company: Froboz Widgets
    +++


    # page.haml in your template
    %html
      %head
        ...
      %body
        ...
        #footer
          Copyright ©#{Time.now.year} #{global.company}. All rights reserved.


# Additional Planned Features
* Additional Markups (RDoc? JavaDoc?)
* Customizing TOC Icons (with nice names, not indexes)

[1]: http://daringfireball.net/projects/markdown/basics
[2]: http://rubyinstaller.org/
[3]: http://msdn.microsoft.com/en-us/library/ms669985(VS.85).aspx
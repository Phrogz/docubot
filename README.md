# About DocuBot
DocuBot is a simple Ruby-based tool for easily creating complex CHM documents from a hierarchy of plain text files. At its simplest:

1. Create a directory hierarchy of text files with the extension .md.
   * This will use [Markdown][1] to convert the files to HTML.

2. Run `docubot mydirectory`
   * DocuBot will create `mydirectory.chm` in short order.
     The CHM will have Table of Contents based on the names of the directories and files.


# Requirements
DocuBot requires [Ruby][2] and Windows. (Windows is required to create the CHM file using Microsoft's (proprietary) [HTML Help Workshop][3].)


# Installing
1. Ensure you're running RubyGems 1.3.5 or newer:
   * `gem update --system`
2. Install the DocuBot gem:
   * `gem install docubot`

This will install the `docubot` binary as well as all necessary supporting files.


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


## Editing the HTML Templates and Stylesheet
TODO

## Using Additional Metadata
TODO

# Additional Planned Features
* Automatic Glossary Links
* Custom Filters and Partials
* Custom Metadata for Directories
* Controlling CHM Indexing
* Additional Markups (Textile, Raw HTML, RDoc, etc.)
* Includes and Supporting File and Dirctories Hidden from the TOC
* Customizing TOC Icons
* Links between documents
* User Variables (e.g. company name for template footer) stored or on command line
* Optional TOC sub-entries for in-page headers

[1]: http://daringfireball.net/projects/markdown/basics
[2]: http://rubyinstaller.org/
[3]: http://msdn.microsoft.com/en-us/library/ms669985(VS.85).aspx
Jekyll Data Pages Generator
===========================

Jekyll allows data to be specified in YAML or JSON format in the `_data`
dir.

If the data is an array, it is straightforward to build an index page,
containing all records, using a Liquid loop. In some occasions,
however, you also want to generate one page per record. Consider, e.g.,
a list of team members, for which you want to generate an individual
page for each member.

This generator allows one to specify data files for which we want to
generate one page per record.

Among the advantages:

-   general purpose: it works with any array of data: people, projects,
    events, ... you name it
-   it manages multiple data sources in the same website

Installation
============

Download `data_page_generator.rb` and put it in the `_plugins` directory
of your website.

Usage
=====

-   Specify in `_config.yml` the data files for which you want
    individual page to be generated.
-   Launch Jekyll

The specification in config.yml is as follows:

    page_gen:
      - index_files: <<true or false>
        data: <<name of the data>>
        template: <<name of the template to use to generate the page>>
        name: <<field used to generate the filename>>
        dir: <<directory in which files are to be generated>>
        extension: <<extension used to generate the filename>>
        filter: <<property to filter data records by>>
      - ...

where:

`index_files`
:   specifies if we want to generate named folders (true) or not
    (false) for the current set of data.  **Optional:** if specified,
    it overrides the value of the global declaration `page_gen-dirs`.

`data`
:   is the name of the data file to read (YAML, Json, or CSV). Use the
    full path if your data is structured in a hierarchy.  For
    instance: `hierarchy.people` will loop over a variable `people` in
    the `_data/hierarchy.yml` file

`name`
:   is the name of a field in data which contains a unique identifier
    that can be used to generate a filename

`name_expr`
:   is an optional Ruby expression used to generate a filename.  The
expression can reference fields of the data being read using the `record`
hash(e.g., `record['first_name'] + "_" + record['last_name']`)
**Optional:** if set, this overrides `name`

`template`
:   is the name of a template to generate the pages (it defaults to the
    value of `data` + ".html"). **Optional:** if not set, the generator
    uses the value of the `data` field

`dir`
:   is the directory where pages are generated (it defaults to the
    value of `data`). **Optional:** if not specified, the generator
    uses the value of the `data` field.

`extension`
:   is the extension of the generated file. **Optional:** if not
    specified, the generator uses "html" extension.

`filter`
:   is a property of each data record that must return a true-ish
    value for the record to be included in the list of files to be
    generated. **Optional:** if not specified, all records from the
    dataset are included (see also `filter_condition`).
    
`filter_condition`
:   is a string containing a Ruby expression which evaluates to a
    true-ish value.  The condition can reference fields of the data
    being read using the `record` hash (e.g., `record['author'] ==
    'George Orwell'`).  **Optional:** if not specified, all records
    from the dataset are included (see also `filter`).

**Notes**

* More than one data source can be specified: the generator iterates over
  each element of the `data_gen` array.
* The same data structure can be referenced different times, maybe
  with different target directories.  This is useful to group pages
  in different directories, using `filter_condition`.

A liquid tag is also made available to generate a link to a given page.
For instance:

       {{ page_name | datapage_url: dir }}

generates a link to `page_name` in `dir`.

Named Folders
=============

By default the plugin generates one filename per record. If you prefer
to generate named folders, set the `page_gen-dirs` to true in
`config.yml`.

Example
=======

1. You have an `members.yml` file stored in the `_data` directory of your
Jekyll website, with the following content:

    - name: adolfo villafiorita
      bio: long bio goes here
    - name: pietro molini
      bio: another long bio
    - name: aaron ciaghi
      bio: another very long bio

Alternatively, you could have `members.json` file stored in the `_data`
directory with the following content and the example would work the
same:

    [
      {
        "name": "adolfo villafiorita",
        "bio": "long bio goes here"
      },
      {
        "name": "pietro molini",
        "bio": "another long bio"
      },
      {
        "name": "aaron ciaghi",
        "bio": "another very long bio"
      }
    ]

2. There is a `profile.html` file stored in the `_layouts` directory:
```
<h1>{{page.name}}</h1>

{{page.bio}}
```
3. `_config.yml` contains the following:

    page_gen:
      - data: 'members'
        template: 'profile'
        name: 'name'
        dir: 'people'

Then, when building the site, this generator will create a directory
`people` containing, for each record in `members.yml`, a file with the
record data formatted according to the `profile.html` layout. The record
used to generate the filename of each page is `name`, sanitized.

    $ cd example
    $ jekyll build
    $ cat _site/people/adolfo-villafiorita.html
    <h1>Adolfo Villafiorita</h1>

    long bio goes here

Check the example directory for a live demo. (Notice that the ruby file
in `_plugins` is a symbolic link; you might have to remove the link and
manually copy the ruby file in the `_plugins` directory, if symbolic
links do not work in your system.)

Filters
=======

There are three different ways which you can use to show only the
relevant records of a data structure in your website:

Do not link uninteresting pages
-------------------------------

Generate pages for all records (relevant and not), but link only the
interesting pages.

The uninteresting pages will still get generated but will not be
easily accessible.  A visitor has to guess the URL to access them.
This is more of a workaround, rather than a solution.
   
This is shown in the `books.md` file, in the section "Books I have
read".  

The filter is applied to the links to tha generated pages.  Pages will
still be generated for all books, but only those for which `book.read`
is true will be easily accessible (since only these have an explicit
link in our website).

Use the `filter` condition
--------------------------

Use the `filter` property.

In this case, all records in your data structure should have a boolean
field, let us say, `publish`.  Pages will be generated only for those
records in which the `publish` field is true(-ish).

Consider the following declaration in `_config.yml`:

    - data: 'books'
      template: 'book'
      name: 'title'
      dir: 'books-i-have-read'
      filter: read  # read is a boolean value in the YML file

In this case, a page will be generated only for the books in which the
field `read` is `true`.


Use the `filter_condition` condition
------------------------------------

Use the `filter_condition` property. 

The field should contain a string which evaluates to a boolean
expression.  The string may reference fields of the data structure
using the `record[<field_name>]` notation, like, for instance in 
`record['author'] == 'George Orwell'`.

In this case pages will be generated only for the records satisfying
the evaluation of the `filter_condition`.

**Example 1.** Consider the following declaration in `_config.yml`:

    - data: 'books'
      template: 'book'
      name: 'title'
      dir: 'books-i-have-not-read'
      filter_condition: "record['read'] == false"

that allows me to generate a list of the books I have **not** read.
The `filter` keyword, in this case, is no good, since I need to test
for falsity (`read` has to be false).

The filter condition allows to select only those records in which
`record['read']` is false.

**Remark**
If you want to filter on nested fields, use multiple `[]`.  For instance:

    filter_condition: "record['did-i']['read'] == false"
    
works with the following data structure:

    - author: Harper Lee
      title: To Kill a Mockingbird
      did-i:
        read: no
      rating: 4.26
      year: 1960
      position: 1


**Example 2.** Consider the following declaration in `_config.yml`:

    - data: 'books'
      template: 'book'
      name: 'title'
      dir: 'books-by-orwell'
      filter_condition: "record['author'] == 'George Orwell'"
      
In this case, I am testing the `author` field and generating pages
only for the books by George Orwell.

As a final consideration, `filter_condition` allows one to deploy
pages in different directories according to specific properties.

Consider the following example:

    - data: 'books'
      template: 'book'
      name: 'title'
      dir: 'books-read'
      filter_condition: "record['read'] == true"
    - data: 'books'
      template: 'book'
      name: 'title'
      dir: 'books-to-read'
      filter_condition: "record['read'] == false"

which splits the `book` data structure in two different folders,
according to the value of the `read` flag.

Of course, such an approach makes sense only for variables with a
limited number of values, since one needs to explicitly specify in
`_config.yml` conditions and target directories.


Generating Filename with an Expression
=============

You can generate filenames with an expression, by replacing `name` with `name_expr`.
For example, if you have data in a .yml file that looks like this:
```
    - first_name: adolfo
      last_name: villafiorita
      bio: long bio goes here
    - first_name: pietro
      last_name: molini
      bio: another long bio
    - first_name: aaron
      last_name: ciaghi
      bio: another very long bio
```

Your `_config.yml` could contain the following:

    page_gen:
      - data: 'members'
        template: 'profile'
        name_expr: record['first_name'] + "_" + record['last_name']
        dir: 'people'


Compatibility
=============

Run with Jekyll 3.1.6, 3.6.2 and 3.8.5, it should also work with
previous versions of Jekyll. Try with the included example and open an
issue if you find any compatibility issue.

Author and Contributors
=======================

[Adolfo Villafiorita](http://ict4g.net/adolfo)
with
[contributions from various authors](https://github.com/avillafiorita/jekyll-datapage_gen/graphs/contributors).

Known Bugs
==========

Some known bugs and an unknown number of unknown bugs.

(See the open issues for the known bugs.)

License
=======

Distributed under the terms of
the [MIT License](http://opensource.org/licenses/MIT).

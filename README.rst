jacinto
=======
Format and validate JSON files. It uses Python as the validating engine but it
is implemented in 100% VimL.

No need to install any formatting library or external dependencies. Just drop
the plugin (fully supports pathogen.vim) in the plugin directory or in your
pathogen ``bundle`` dir and start validating away!

Usage
-----
This plugin provides a single command with a few optional arguments::

    :Jacinto

All optional arguments to the above command are tab-completable. The arguments
available are::

    validate
    format
    syntax
    version

Validation
----------
When ``:Jacinto validate`` is called, the whole file goes through the
validation engine to report back on any errors. If none are present a message
is returned, similar to::

    :jacinto ==> Valid  JSON!

When validation fails, it shows the actual error message from the engine and it
places your cursor in the line and column where the error reports is having
a problem. For example, you could see a message like this one when an error
occurs::

    Expecting , delimiter: line 10 column 15 (char 278)

The cursor should be automatically placed on that line and that column.

Formatting
----------
When ``:Jacinto format`` is called it does two things: validates first and
formats second. If validation fails, it displays the error message and places
the cursor in the line and column where the error was reported, otherwise, if
the JSON is valid it will format the **whole file**.

**You cannot validate a portion of JSON**

It is all or nothing here. 

When JSON has been formatted you can expect a message like::

    :jacinto ==> Formatted valid JSON

Syntax
------
More of a hack really, we just set the filetype of the document to be
``Javascript`` and let Vim take over the actual syntax highlighting for us. If
you have any special behavior for Javascript you should be aware of this when
triggering the highlighting (for example, indentation and tab spaces).

The plugin also includes a callabale so you can trigger this automatically
every time you read a JSON file. If you would want this functionality you would
need to add a line similar to this one::

    autocmd BufNewFile,BufRead *.json call jacinto#syntax()


Python
------
Probably there is no need to know about Python as the validating engine but
that is what we use on the back end. It calls ``python -m json.tool
<filename>`` to format the file and to find any errors.

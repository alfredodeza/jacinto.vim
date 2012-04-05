jacinto
=======
Format and validate JSON files. It uses Python as the validating engine but it
is implemented in 100% VimL.

No need to install any formatting library or external dependencies. Just drop
the plugin (fully supports pathogen.vim) in the plugin directory or in your
pathogen ``bundle`` dir and start validating away!

Python
------
Probably there is no need to know about Python as the validating engine but
that is what we use on the back end. It calls ``python -m json.tool
<filename>`` to format the file and to find any errors.

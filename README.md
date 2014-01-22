Journal.txt
===========
Journal.txt is a command line journaling program inspired by [Todo.txt](http://todotxt.com). It serves to manage a journal.txt file.

Usage
-----
`journal action <date> <filter>`

###Actions
The following actions are currently supported:

* new - Create a new journal entry for today (default action if none given).
* edit - Edit the entry for the given date in the format MM/DD/YY.
* delete - Delete the entry for the given date in the format MM/DD/YY.
* list - Lists all entries unless given a filter. Filter is in the format MM/DD/YY with \* being used as a wildcard: 01/\*/14 to list all entries from January 2014.


###Additional Details
* journal.txt file will live wherever you run the journal script.
* The only date format recognized is MM/DD/YY.

Installation
------------

* `cd` into your preferred installation directory, ie ~/packages
* Get the code in whatever manor you choose:
  * Clone the repo.

    ```
    git clone https://github.com/greenmanspirit/journal.txt.git
    ```
  * Download and extract the zip.

    ```
    wget https://github.com/greenmanspirit/journal.txt/archive/master.zip
    unzip master.zip
    rm master.zip
    mv journal.txt-master journal.txt
    ```
* Installation suggestions
  * Place journal.txt into your path or create a symbolic link to journal.txt/journal in a directory already in your path.
  * If you are interested is saving keystrokes, create the alias j=journal.

journal.txt File Format
-----------------------
There are three tags needed for each entry in your journal.txt file in order for it to be compatible with this application.

* ENTRYSTART - This designates the beginning of a journal entry,
* ENTRYDATE - The date of the journal entry in the format MM/DD/YY, must fome directly after ENTRYSTART.
* ENTRYEND - This designates the end of a journal entry.

Example journal.txt file:
> ENTRYSTART  
> ENTRYDATE 01/01/14  
> This is a journal entry!  
>
> Isn't it cool?  
> ENTRYEND  
> ENTRYSTART  
> ENTRYDATE 12/31/13  
> This is a second journal entry!  
> ENTRYEND

Testing
-------
The test directory contains the Journal.txt testing scripts. To run them, do `cd test && ./test`. The test scripts generate and remove files as they go, including the journal.txt file. For the safest and cleanest run of the tests, run `test` in the test directory.

Contact
-------
If you have any issues or feature requests, please report them on the project's [GitHub issue tracker](https://github.com/greenmanspirit/journal.txt/issues) if you cannot find a ticket on them. If you want to contact me for any other reason, you can at <dev@adamhobaugh.com>.

Journal.txt
===========
Journal.txt is a command line journaling program inspired by [Todo.txt](http://todotxt.com). It serves to manage a journal.txt file.

Usage
-----
`journal action <date>`

###Actions
The following actions are currently supported

* new - Create a new journal entry for today (default action if none given)
* edit - Edit an entry for the given date in format MM/DD/YY

###Additional Details
* The journal script needs to be run in the same directory as journal.rb and the journal.txt file
* The only date format recognized is MM/DD/YY

Installation
------------
Cloning the repo is all that you need to do in it's current state.

journal.txt File Format
-----------------------
There are three tags needed for each entry in your journal.txt file in order for it to be compatible with this application.

* ENTRYSTART - This designates the beginning of a journal entry
* ENTRYEND - This designates the end of a journal entry
* ENTRYDATE - The date of the journal entry in the format MM/DD/YY

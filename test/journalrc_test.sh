################################################################################
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Adam C Hobaugh
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
################################################################################

#
# This file contains all of the tests of the .journalrc file and functionality
#

#These tests need the journal.txt file to exist, so create it
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt

start_test "Journal Don't Create .journalrc"
[ -f $HOME/.journalrc ] && rm $HOME/.journalrc
echo "n" | ../journal > output
assert_not_exists $HOME/.journalrc
assert_file_contains output "You do not have ~/.journalrc"

start_test "Journal Create .journalrc"
[ -f $HOME/.journalrc ] && rm $HOME/.journalrc
echo "y" | ../journal > output
assert_exists $HOME/.journalrc
assert_file_contains output "Created ~/.journalrc"
assert_file_contains $HOME/.journalrc "EDITOR=vim"
assert_file_contains $HOME/.journalrc "FILEDIR=$HOME"

start_test "Journal use .journalrc EDITOR on new"
echo "EDITOR=emacs
FILEDIR=$HOME" > $HOME/.journalrc
export VALUE="Emacs Entry"
../journal
assert_exists emacs_out
[ -f emacs_out ] && rm emacs_out

start_test "Journal use .journalrc EDITOR on edit"
echo "EDITOR=emacs
FILEDIR=$HOME" > $HOME/.journalrc
export VALUE="Emacs Entry"
../journal edit $ENTRY1D
assert_exists emacs_out
[ -f emacs_out ] && rm emacs_out

start_test "Journal use .journalrc FILEDIR"
echo "EDITOR=vim
FILEDIR=$HOME/journal" > $HOME/.journalrc
mkdir $HOME/journal
export VALUE="FILEDIR entry"
echo "y" | ../journal > /dev/null
assert_exists $HOME/journal/journal.txt
rm -rf $HOME/journal

start_test "Journal still add new entry without .journalrc"
[ -f $HOME/.journalrc ] && rm $HOME/.journalrc
export VALUE="Entry 4"
echo "n" | ../journal > /dev/null
assert_contains "Entry 4"

start_test "Journal still edit entry without .journalrc"
[ -f $HOME/.journalrc ] && rm $HOME/.journalrc
export VALUE="Entry 5"
echo "n" | ../journal edit $ENTRY1D > /dev/null
assert_contains "Entry 5"

start_test "Journal ignore bad settings in .journalrc"
echo "$JOURNALRC
FOO=bar" > $HOME/.journalrc
../journal > output
assert_file_contains output "ignoring: FOO"

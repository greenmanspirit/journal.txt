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
# This file contains all of the tests of the journal.txt file and functionality
#

#These tests needs a .journalrc file existing to create it
echo "$JOURNALRC" > $HOME/.journalrc

start_test "Journal Don't Create File"
[ -f $HOME/journal.txt ] && rm $HOME/journal.txt
echo "n" | ../journal &>/dev/null
assert_not_exists $HOME/journal.txt

start_test "Journal Create File"
[ -f $HOME/journal.txt ] && rm $HOME/journal.txt
echo "y" | ../journal > /dev/null
assert_exists $HOME/journal.txt

start_test "Entry Format"
[ -f $HOME/journal.txt ] && rm $HOME/journal.txt
DATE=`date +'%D'`
export VALUE="Entry 1"
echo "y" | ../journal > /dev/null
assert_contains_on_line "ENTRYSTART" 1
assert_contains_on_line "ENTRYDATE $DATE" 2
assert_contains_on_line "Entry 1" 3
assert_contains_on_line "ENTRYEND" 4

start_test "Descending Entries on New"
echo "$ENTRY1" > $HOME/journal.txt
DATE=`date +'%D'`
export VALUE="Entry 2"
../journal > /dev/null
assert_contains_on_line "ENTRYSTART" 1
assert_contains_on_line "ENTRYDATE $DATE" 2
assert_contains_on_line "ENTRYSTART" 5
assert_contains_on_line "ENTRYDATE $ENTRY1D" 6

start_test "Descending Entries on Edit"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
export VALUE="Entry 4"
../journal edit $ENTRY2D > /dev/null
assert_contains_on_line "ENTRYSTART" 1
assert_contains_on_line "ENTRYDATE $ENTRY1D" 2
assert_contains_on_line "ENTRYSTART" 5
assert_contains_on_line "ENTRYDATE $ENTRY2D" 6
assert_contains_on_line "ENTRYSTART" 9
assert_contains_on_line "ENTRYDATE $ENTRY3D" 10

start_test "Descending Entries on Delete"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
echo "y" | ../journal delete $ENTRY2D > /dev/null
assert_contains_on_line "ENTRYSTART" 1
assert_contains_on_line "ENTRYDATE $ENTRY1D" 2
assert_contains_on_line "ENTRYSTART" 5
assert_contains_on_line "ENTRYDATE $ENTRY3D" 6

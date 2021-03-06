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
# This file contains all of the tests of the edit entry functionality
#

#These tests needs a .journalrc file existing so create it
echo "$JOURNALRC" > $HOME/.journalrc

start_test "Edit Entry"
echo "$ENTRY1" > $HOME/journal.txt
export VALUE="$ENTRY2V"
../journal edit $ENTRY1D
assert_contains "$VALUE"
assert_not_contains "$ENTRY1V"

start_test "Edit First Entry"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
export VALUE="Entry 4"
../journal edit $ENTRY1D
assert_contains "$VALUE"
assert_not_contains "$ENTRY1V"
assert_contains "$ENTRY2V"
assert_contains "$ENTRY3V"

start_test "Edit Second Entry"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
export VALUE="Entry 4"
../journal edit $ENTRY2D
assert_contains "$VALUE"
assert_contains "$ENTRY1V"
assert_not_contains "$ENTRY2V"
assert_contains "$ENTRY3V"

start_test "Edit Third Entry"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
export VALUE="Entry 4"
../journal edit $ENTRY3D
assert_contains "$VALUE"
assert_contains "$ENTRY1V"
assert_contains "$ENTRY2V"
assert_not_contains "$ENTRY3V"

start_test "Empty Edit No Delete"
echo "$ENTRY1" > $HOME/journal.txt
export VALUE=""
echo "n" | ../journal edit $ENTRY1D > output
assert_file_contains output "Leaving the entry"
assert_contains "$ENTRY1V"

start_test "Empty Edit Yes Delete"
echo "$ENTRY1" > $HOME/journal.txt
export VALUE=""
echo "y
y" | ../journal edit $ENTRY1D > output
assert_file_contains output "Deleted entry"
assert_not_contains "$ENTRY1V"

start_test "Whitespace Empty Edit Space"
echo "$ENTRY1" > $HOME/journal.txt
#Below is a space, tab and newline
export VALUE=" 	
"
echo "n" | ../journal edit $ENTRY1D > output
assert_file_contains output "Leaving the entry"

start_test "Edit No Entry"
echo "$ENTRY1" > $HOME/journal.txt
../journal edit $ENTRY2D > output
assert_file_contains output "No entry for $ENTRY2D"

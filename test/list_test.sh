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
# This file contains all of the tests of the list entries functionality
#

#These tests needs a .journalrc and journal.txt file existing so create it
echo "$JOURNALRC" > $HOME/.journalrc
echo "$ENTRY1
$ENTRY2
$ENTRY3
ENTRYSTART
ENTRYDATE 11/15/13
Entry 4
ENDENTRY" > $HOME/journal.txt

start_test "List Entries w/o Filter"
../journal list > output
assert_file_contains output "$ENTRY1D"
assert_file_contains output "$ENTRY2D"
assert_file_contains output "$ENTRY3D"
assert_file_contains output "11/15/13"
assert_file_contains output "4"

start_test "List Entries Filter */01/14"
../journal list t*/01/14 > output
assert_file_contains output "/^\d\d\/01\/14$/"
assert_file_not_contains output "$ENTRY1D"
assert_file_contains output "$ENTRY2D"
assert_file_not_contains output "$ENTRY3D"
assert_file_not_contains output "11/15/13"
assert_file_contains output "1"

start_test "List Entries Filter 11/*/13"
../journal list t11/*/13 > output
assert_file_contains output "/^11\/\d\d\/13$/"
assert_file_not_contains output "$ENTRY1D"
assert_file_not_contains output "$ENTRY2D"
assert_file_not_contains output "$ENTRY3D"
assert_file_contains output "11/15/13"
assert_file_contains output "1"

start_test "List Entries Filter 11/15/*"
../journal list t11/15/* > output
assert_file_contains output "/^11\/15\/\d\d$/"
assert_file_not_contains output "$ENTRY1D"
assert_file_not_contains output "$ENTRY2D"
assert_file_not_contains output "$ENTRY3D"
assert_file_contains output "11/15/13"
assert_file_contains output "1"

start_test "List Entries Filter */*/14"
../journal list t*/*/14 > output
assert_file_contains output "/^\d\d\/\d\d\/14$/"
assert_file_contains output "$ENTRY1D"
assert_file_contains output "$ENTRY2D"
assert_file_not_contains output "$ENTRY3D"
assert_file_not_contains output "11/15/13"
assert_file_contains output "2"

start_test "List Entries Filter */01/*"
../journal list t*/01/* > output
assert_file_contains output "/^\d\d\/01\/\d\d$/"
assert_file_not_contains output "$ENTRY1D"
assert_file_contains output "$ENTRY2D"
assert_file_not_contains output "$ENTRY3D"
assert_file_not_contains output "11/15/13"
assert_file_contains output "1"

start_test "List Entries Filter 12/*/*"
../journal list t12/*/* > output
assert_file_contains output "/^12\/\d\d\/\d\d$/"
assert_file_not_contains output "$ENTRY1D"
assert_file_not_contains output "$ENTRY2D"
assert_file_contains output "$ENTRY3D"
assert_file_not_contains output "11/15/13"
assert_file_contains output "1"

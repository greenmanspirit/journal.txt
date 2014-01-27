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
# This file contains all of the tests of the new entry functionality
#

#These tests needs a .journalrc file existing to create it
echo "$JOURNALRC" > .journalrc

start_test "New Entry"
[ -f journal.txt ] && rm journal.txt
export VALUE="Entry 1"
echo "y" | ../journal > /dev/null
assert_contains "$VALUE"

start_test "Second New Entry Should Edit"
VALUE2=$VALUE
export VALUE="Entry 2"
../journal
assert_contains "$VALUE"
assert_not_contains "$VALUE2"

start_test "Blank New Entry Should Not Create"
[ -f journal.txt ] && rm journal.txt
export VALUE=""
echo "y" | ../journal > output
assert_file_contains output "No entry created"
assert_zerolength

start_test "Unwritten New Entry Should Not Create"
[ -f journal.txt ] && rm journal.txt
export VALUE="no_write"
echo "y" | ../journal > output
assert_file_contains output "No entry created"
assert_zerolength

start_test "Write Entry"
[ -f journal.txt ] && rm journal.txt
DATE=`date +'%D'`
export VALUE="Entry 1"
echo "y" | ../journal > /dev/null
assert_contains_on_line "ENTRYSTART" 1
assert_contains_on_line "ENTRYDATE $DATE" 2
assert_contains_on_line "Entry 1" 3
assert_contains_on_line "ENTRYEND" 4

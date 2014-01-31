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
# This file contains all of the tests of the journal.txt file and  functionality
#

#These tests needs a .journalrc file existing to create it
echo "$JOURNALRC" > .journalrc

start_test "View entry"
echo "$ENTRY1" > journal.txt
../journal view $ENTRY1D > output
assert_file_contains output "$ENTRY1D"
assert_file_contains output "$ENTRY1V"

start_test "View no entry"
echo "$ENTRY1" > journal.txt
../journal view $ENTRY2D > output
assert_file_contains output "No entry"

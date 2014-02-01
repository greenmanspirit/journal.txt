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
# This file contains all of the tests of the delete entry functionality
#

#These tests needs a .journalrc file existing so create it
echo "$JOURNALRC" > $HOME/.journalrc

start_test "Delete Entry"
echo "$ENTRY1" > $HOME/journal.txt
echo "y" | ../journal delete $ENTRY1D > /dev/null
assert_not_contains "$ENTRY1V"

start_test "Delete First Entry"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
echo "y" | ../journal delete $ENTRY1D > /dev/null
assert_not_contains "$ENTRY1V"
assert_contains "$ENTRY2V"
assert_contains "$ENTRY3V"

start_test "Delete Second Entry"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
echo "y" | ../journal delete $ENTRY2D > /dev/null
assert_contains "$ENTRY1V"
assert_not_contains "$ENTRY2V"
assert_contains "$ENTRY3V"

start_test "Delete Third Entry"
echo "$ENTRY1
$ENTRY2
$ENTRY3" > $HOME/journal.txt
echo "y" | ../journal delete $ENTRY3D > /dev/null
assert_contains "$ENTRY1V"
assert_contains "$ENTRY2V"
assert_not_contains "$ENTRY3V"

start_test "No Delete Entry"
echo "$ENTRY1" > $HOME/journal.txt
echo "n" | ../journal delete $ENTRY1D > /dev/null
assert_contains "$ENTRY1V"

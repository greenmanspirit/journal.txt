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

#test_cleanup - Utility function to save lines below
#  Inputs:
#    $1 - The journal file we are dealing with
#  Returns:
#    None
test_cleanup()
{
  assert_not_exists $1.new
  assert_not_exists $1.before
  assert_not_exists $1.after
}
#These tests needs a .journalrc file existing to create it
echo "$JOURNALRC" > .journalrc

start_test "Cleanup New Entry"
[ -f journal.txt ] && rm journal.txt
export VALUE=$ENTRY1V
echo "y" | ../journal > /dev/null
assert_contains "$ENTRY1V"
test_cleanup journal.txt

start_test "Cleanup Edit"
echo "$ENTRY1" > journal.txt
export VALUE="$ENTRY2V"
../journal edit $ENTRY1D > /dev/null
assert_contains "$ENTRY2V"
test_cleanup journal.txt

start_test "Cleanup Edit not found"
echo "$ENTRY1" > journal.txt
../journal edit $ENTRY2D > output
assert_file_contains output "No entry"
test_cleanup journal.txt

start_test "Cleanup Edit empty entry no"
echo "$ENTRY1" > journal.txt
export VALUE=""
echo "n" | ../journal edit $ENTRY1D > output
assert_file_contains output "Leaving"
test_cleanup journal.txt

start_test "Cleanup Delete"
echo "$ENTRY1" > journal.txt
echo "y" | ../journal delete $ENTRY1D > /dev/null
assert_not_contains "$ENTRY1V"
test_cleanup journal.txt

start_test "Cleanup Delete not found"
echo "$ENTRY1" > journal.txt
../journal delete $ENTRY2D > output
assert_file_contains output "No entry"
test_cleanup journal.txt

start_test "Cleanup Delete no"
echo "$ENTRY1" > journal.txt
echo "n" | ../journal delete $ENTRY1D > /dev/null
assert_contains "$ENTRY1V"
test_cleanup journal.txt

HOMEB=$HOME
HOME=$SCRIPT_DIR/new_home
mkdir $HOME
echo "FILEDIR=$HOME" > $HOME/.journalrc

start_test "Cleanup New Entry : Diff home"
[ -f $HOME/journal.txt ] && rm $HOME/journal.txt
export VALUE=$ENTRY1V
echo "y" | ../journal > /dev/null
assert_file_contains $HOME/journal.txt "$ENTRY1V"
test_cleanup $HOME/journal.txt

start_test "Cleanup Edit : Diff home"
echo "$ENTRY1" > $HOME/journal.txt
export VALUE="$ENTRY2V"
../journal edit $ENTRY1D > /dev/null
assert_file_contains $HOME/journal.txt "$ENTRY2V"
test_cleanup $HOME/journal.txt

start_test "Cleanup Edit not found : Diff home"
echo "$ENTRY1" > $HOME/journal.txt
../journal edit $ENTRY2D > output
assert_file_contains output "No entry"
test_cleanup $HOME/journal.txt

start_test "Cleanup Edit empty entry no : Diff home"
echo "$ENTRY1" > $HOME/journal.txt
export VALUE=""
echo "n" | ../journal edit $ENTRY1D > output
assert_file_contains output "Leaving"
test_cleanup $HOME/journal.txt

start_test "Cleanup Delete : Diff home"
echo "$ENTRY1" > $HOME/journal.txt
echo "y" | ../journal delete $ENTRY1D > /dev/null
assert_file_not_contains $HOME/journal.txt "$ENTRY1V"
test_cleanup $HOME/journal.txt

start_test "Cleanup Delete not found : Diff home"
echo "$ENTRY1" > $HOME/journal.txt
../journal delete $ENTRY2D > output
assert_file_contains output "No entry"
test_cleanup $HOME/journal.txt

start_test "Cleanup Delete no : Diff home"
echo "$ENTRY1" > $HOME/journal.txt
echo "n" | ../journal delete $ENTRY1D > /dev/null
assert_file_contains $HOME/journal.txt "$ENTRY1V"
test_cleanup $HOME/journal.txt

rm -rf $HOME
HOME=$HOMEB

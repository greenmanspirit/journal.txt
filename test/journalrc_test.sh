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
$ENTRY2" > journal.txt

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

start_test "Journal Create .journalrc in \$HOME"
#An explination here, since $HOME is set to the test directory, the above tests
#  don't actually ensure that the file is being created in $HOME
[ -d $SCRIPT_DIR/new_home ] && rm -rf $SCRIPT_DIR/new_home
mkdir $SCRIPT_DIR/new_home
HOMEB=$HOME
HOME=$SCRIPT_DIR/new_home
echo "y" | ../journal > output
assert_exists $HOME/.journalrc
rm -rf $HOME
HOME=$HOMEB

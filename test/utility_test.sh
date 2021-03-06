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
# This file contains all of the tests of the utility functions
#

#These tests needs a .journalrc file existing so create it
echo "$JOURNALRC" > $HOME/.journalrc

start_test "Query User"
[ -f $HOME/journal.txt ] && rm $HOME/journal.txt
echo "a
b
y" | ../journal > output
COUNT=`sed 's/n\] /n\] \n/g' output | grep -c 'does not exist'`
assert_count $COUNT 3

start_test "Valid Date Month"
for i in {1..12}
do
  echo "" > $HOME/journal.txt
  DATE=`printf %02d/01/14 $i`
  ../journal edit $DATE > output
  assert_file_contains output "No entry for $DATE"
done

start_test "Valid Date Day"
for i in {1..31}
do
  echo "" > $HOME/journal.txt
  DATE=`printf 01/%02d/14 $i`
  ../journal edit $DATE > output
  assert_file_contains output "No entry for $DATE"
done

start_test "Valid Date Bad Month"
for i in -1 0 13 14
do
  echo "" > $HOME/journal.txt
  DATE=`printf %02d/01/14 $i`
  ../journal edit $DATE > output
  assert_file_contains output "Invalid Date"
done

start_test "Valid Date Bad Day"
for i in -1 0 29 32
do
  echo "" > $HOME/journal.txt
  DATE=`printf 02/%02d/14 $i`
  ../journal edit $DATE > output
  assert_file_contains output "Invalid Date"
done

start_test "Valid Date Bad Month Format"
echo "" > $HOME/journal.txt
DATE=1/01/14
../journal edit $DATE > output
assert_file_contains output "Invalid Date"

start_test "Valid Date Bad Day Format"
echo "" > $HOME/journal.txt
DATE=01/1/14
../journal edit $DATE > output
assert_file_contains output "Invalid Date"

start_test "Valid Date Bad Year Format"
echo "" > $HOME/journal.txt
DATE=01/01/2014
../journal edit $DATE > output
assert_file_contains output "Invalid Date"

start_test "Valid Date Bad on Delete"
echo "" > $HOME/journal.txt
DATE=01/01/2014
../journal delete $DATE > output
assert_file_contains output "Invalid Date"

start_test "Valid Date Bad on View"
echo "" > $HOME/journal.txt
DATE=01/01/2014
../journal view $DATE > output
assert_file_contains output "Invalid Date"

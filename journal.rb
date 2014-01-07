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

class Journal
  def initialize(journal_file)
    #Just set the filename for the object and grab the current time
    @filename = journal_file
    @now = Time.now
  end

  #new_entry - Create a new journal entry for todays date
  #  Inputs:
  #    None
  #  Return:
  #    None
  def new_entry
    #Get the new journal entry
    tmp_filename = "/tmp/journal_#{ENV['USER']}_#{@now.strftime('%s')}.txt"
    system "vim #{tmp_filename}"

    #If the user just quit their editor without saving anything, exit gracefully
    if !File.exists?(tmp_filename)
      puts "No entry created for today."
      return
    end

    #Create File objects for the files needed
    new_file = File.new("#{@filename}.new", 'w+')
    old_file = File.new(@filename, 'r')

    #Add the new journal entry
    entry_contents = ""
    File.open tmp_filename do |t|
      t.each do |line|
         entry_contents += line
      end
    end
    write_entry(new_file, entry_contents, @now.strftime('%D'))

    #Add the rest of the journal
    old_file.each do |line|
      new_file.print line
    end

    #File cleanup
    File.delete tmp_filename
    File.rename("#{@filename}.new", @filename)
  end

  #edit_entry - Edit the journal entry for the given date
  #  Inputs:
  #    date - Date we want to edit
  #  Returns:
  #    None
  def edit_entry(date)
    #Prep the files I will need
    before_file = File.new("#{@filename}.before", 'w+')
    after_file = File.new("#{@filename}.after", 'w+')
    tmp_filename = "/tmp/journal_#{ENV['USER']}_#{@now.strftime('%s')}.txt"
    tmp_file = File.new(tmp_filename, 'w+')
    new_file = File.new("#{@filename}.new", 'w+')

    #Get the requested entry or state no entry if none returned
    entry = find_entry(before_file, after_file, date) || "No entry for #{date}"

    #Place the entry into the tmpfile and open it up for the user to edit
    tmp_file.print entry
    tmp_file.close
    system "vim #{tmp_filename}"

    #Get the edited contents
    entry_contents = ""
    File.open tmp_filename do |t|
      t.each do |line|
         entry_contents += line
      end
    end

    #Print the the before content, edited entry and after entry to a new file
    before_file.each do |line|
      new_file.print line
    end
    write_entry(new_file, entry_contents, date)
    after_file.each do |line|
      new_file.print line
    end

    #Close out the files and clean everything up
    before_file.close
    after_file.close
    File.delete tmp_filename
    File.delete "#{@filename}.before"
    File.delete "#{@filename}.after"
    File.rename("#{@filename}.new", @filename)
  end


  private

  #find_entry - Tries to find a journal entry for a given date
  #  Inputs:
  #    before_file - File to hold contents before the requested entry
  #    after_file - File to hold contents after the requested entry
  #    date - Date we want an entry for
  #  Returns:
  #    False if no entry found
  #    String containing the requested entry if found
  def find_entry(before_file, after_file, date)
    #Prep the variables I will use to find the entry
    entry_found = false
    entry_complete = false
    current_entry = ""
    current_entry_date = ""
    requested_entry = ""

    #Open the journal file so we can search it
    file = File.new(@filename, 'r')

    #Since we are working with a text file that should be just as easibly human
    #  edited, there are no indexes at the beginning of the file to avoid a line
    #  by line search so I try to be as efficient as I can by keeping O(x).
    file.each do |line|
      #If we are at the beginning of an entry
      if line == "ENTRYSTART\n"
        #Clear the previous entry so I can start reading the current one
        current_entry = ""
        next
      #If we are at the end of an entry
      elsif line == "ENTRYEND\n"
        #If we haven't found the entry we are looking for, write the entry to 
        #  the before file
        if !entry_found
          write_entry(before_file, current_entry, current_entry_date)
        #If we found the entry but not stored to be returned, store it and mark
        #  complete
        elsif entry_found && !entry_complete
          requested_entry = current_entry
          entry_complete = true
        #If we have marked complete, write the entry to the after file
        elsif entry_complete
          write_entry(after_file, current_entry, current_entry_date)
        end
      #If we are on a date line, test the date to see if it's the one we want
      elsif line.start_with?("ENTRYDATE ")
        current_entry_date = line.split(' ')[1]
        if current_entry_date == date
          entry_found = true
        end
        next
      end

      #If this is any old line, add it to the rest of the current entry
      current_entry += line
    end

    #Close the journal file and rewind the others so I can read them in the 
    #  calling file
    file.close
    before_file.rewind
    after_file.rewind

    #If we didn't find the requested entry, return false, otherwise, return the
    #  entry. This is to take advantage of the || assignment
    if(requested_entry == "")
      return false
    else
      return requested_entry
    end
  end

  #write_entry - Write full entry to whatever file we are given
  #  Inputs:
  #    file - File we are writing to
  #    content - The entries content
  #    date - The date associated with the entry
  #  Returns:
  #    None
  def write_entry(file, content, date)
    file.puts "ENTRYSTART"
    file.puts "ENTRYDATE #{date}"
    file.puts content
    file.puts "ENTRYEND"
  end
end

#usage - Prints applications usage message
#  Inputs:
#    None
#  Returns:
#    None
def usage
  puts "Usage: journal action <date>"
  puts "Actions:"
  puts "  new - Create a new journal entry for today"
  puts "  edit - Edit an entry for the given date in format MM/DD/YY"
  exit
end

#Create a new journal object fo the journal.txt file
journal = Journal.new 'journal.txt'

#Check to see what action was given as the first argument
case ARGV[0]
  #Both "new" and no action given signify a new entry
  when "new", nil
    journal.new_entry
  when "edit"
    #Require the date object to take advantage of its valid_date? method
    require 'date'
    #Basically, if we are in edit, then the second argument has to exist, has to
    #  be in the format MM/DD/YY and has to be a valid date. If all that is the
    #  case, then edit the entry for that date else warn.
    if !ARGV[1].nil? &&
        !/(\d{2}\/\d{2}\/\d{2})/.match(ARGV[1]).nil? &&
        Date.valid_date?(Integer(ARGV[1][6..7]),
                          Integer(ARGV[1][0..1]),
                          Integer(ARGV[1][3..4]))
      journal.edit_entry ARGV[1]
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
    end
  else
    #If an unrecognized action, print usage.
    usage
end

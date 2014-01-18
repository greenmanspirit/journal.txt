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

#Require date in order to make use of its functions
require "date"

class Journal
  def initialize(journal_file)
    #Just set the filename for the object
    @filename = journal_file

    #Check for the existance of the journal file and create if it doesn't exist
    #  and user wants to create it, otherwise exit
    if !File.exist? @filename
      #print "Journal file [#{@filename}] does not exist. "
      #print "Would you like to create it? [y/n](n) "
      #if STDIN.gets.chomp.downcase == "y"
      question = "Journal file [#{@filename}] does not exist?"
      if query_user(question, "y", "n") == "y"
        File.open(@filename, "w") do |f|
          puts "Created #{@filename}"
        end
      else
        puts "Cannot work without a journal file, exiting."
        exit
      end
    end
  end

  #new_entry - Create a new journal entry for todays date
  #  Inputs:
  #    None
  #  Return:
  #    None
  def new_entry
    #Get todays date for use below
    todays_date = Date.today

    #Open the journal and if the file has contents check the second line to see 
    #  if it was done today and pass off the work to edit
    old_file = File.new(@filename, "r")
    if !File.zero? @filename
      old_file.gets
      date = old_file.gets
      if(date.split(" ")[1] == todays_date)
        old_file.close
        edit_entry todays_date
        return
      else
        #If this isn't an entry for today, rewind the file to be used below
        old_file.rewind
      end
    end

    #Get the new journal entry
    tmp_filename = "/tmp/journal_#{ENV["USER"]}_#{Time.now.strftime("%s")}.txt"
    system "vim #{tmp_filename}"

    #If the user just quit their editor without saving anything, exit gracefully
    if !File.exists?(tmp_filename) || File.zero?(tmp_filename)
      puts "No entry created for today."
      return
    end

    #Create File objects for the files needed
    new_file = File.new("#{@filename}.new", "w+")

    #Add the new journal entry
    entry_contents = ""
    tmp_file = File.open(tmp_filename, "r")
    tmp_file.each do |line|
       entry_contents += line
    end
    write_entry(new_file, entry_contents, todays_date)

    #Add the rest of the journal
    write_file(old_file, new_file)

    #File cleanup
    cleanup(old_file, tmp_file)
    new_file.close
    File.rename("#{@filename}.new", @filename)
  end

  #edit_entry - Edit the journal entry for the given date
  #  Inputs:
  #    date - Date we want to edit
  #  Returns:
  #    None
  def edit_entry(date)
    #Prep the files I will need
    before_file = File.new("#{@filename}.before", "w+")
    after_file = File.new("#{@filename}.after", "w+")
    tmp_filename = "/tmp/journal_#{ENV["USER"]}_#{Time.now.strftime("%s")}.txt"
    tmp_file = File.new(tmp_filename, "w+")
    new_file = File.new("#{@filename}.new", "w+")

    #Get the requested entry or state no entry if none returned
    entry = find_entry(before_file, after_file, date)
    if !entry 
      puts "No entry for #{date.strftime("%D")}"
      cleanup(before_file, after_file, tmp_file, new_file)
      exit
    end

    #Place the entry into the tmpfile and open it up for the user to edit
    tmp_file.print entry
    tmp_file.close
    system "vim #{tmp_filename}"

    #Get the edited contents
    entry_contents = ""
    tmp_file = File.open(tmp_filename, "r")
    tmp_file.each do |line|
      entry_contents += line
    end

    #If the user emptied the file, that is essentially a delete, ask if they
    #  want to delete the entry instead, otherwise, we won't edit the entry
    if entry_contents.empty?
      puts "This would create an empty journal entry."
      question = "Would you like to delete the entry?"
      if query_user(question, "y", "n") == "n"
        puts "Leaving the entry as is."

        #Close out the files and clean everything up
        cleanup(before_file, after_file, tmp_file, new_file)
        exit
      else
        delete_entry date
        return
      end
    end

    #Print the the before content, edited entry and after entry to a new file
    write_file(before_file, new_file)
    write_entry(new_file, entry_contents, date)
    write_file(after_file, new_file)

    #Close out the files and clean everything up
    cleanup(before_file, after_file, tmp_file)
    new_file.close
    File.rename("#{@filename}.new", @filename)
  end

  #delete_entry - Deletes an entry for a given date
  #  Inputs:
  #    date - Date to be deleted in the format
  #  Returns:
  #    None
  def delete_entry(date)
    #Prep the files I will need
    before_file = File.new("#{@filename}.before", "w+")
    after_file = File.new("#{@filename}.after", "w+")
    new_file = File.new("#{@filename}.new", "w+")

    #Get the request entry if it exists
    entry = find_entry(before_file, after_file, date)

    #If we didn't find an entry, exit gracefully
    if entry == false
      puts "No entry to delete for #{date.strftime("%D")}"
      cleanup(before_file, after_file, new_file)
      exit
    else
      #Make sure user wants to delete the entry, if not, exit gracefully
      question = "Are you sure you want to delete the entry for #{date.strftime("%D")}?"
      if query_user(question, "y", "n") == "n"
        cleanup(before_file, after_file)
        exit
      end
      #Print the before content and after content to a new file
      write_file(before_file, new_file)
      write_file(after_file, new_file)
      puts "Deleted entry"
    end

    cleanup(before_file, after_file)
    new_file.close
    File.rename("#{@filename}.new", @filename)
  end

  #list_entries - Lists entry dates 
  #  Inputs:
  #    filter - String to filter dates by in format MM/DD/YY with * wildcard
  #  Returns:
  #    None
  def list_entries(filter)
    #Open the file so we can search it
    file = File.open(@filename, 'r');

    #If we were given a filter, process it
    if !filter.nil?
      #Split the filter up
      month, day, year = filter.split "/"
      #Check each part for a wildcard and put in \d* where necessary
      if month == "*"
        month = "\\d*"
      end
      if day == "*"
        day = "\\d*"
      end
      if year == "*"
        year = "\\d*"
      end
    else
      #Set default regex pattern for each part
      month = day = year = "\\d*"
    end

    #Build the regex
    filter_regex = /#{month}\/#{day}\/#{year}/

    #This is to keep track of how many entries we have found
    count = 0

    #Loop through the file testing lines for date
    file.each do |line|
      if line.start_with?("ENTRYDATE ")
        date = line.split(" ")[1]
        #If we found a date we care about, print it out
        if !filter_regex.match(date).nil?
          puts date
          count += 1
        end
      end
    end

    #Tell the user how many we have found
    puts "Found #{count} entries"
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
    file = File.new(@filename, "r")

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
        current_entry_date = Date.strptime(line.split(" ")[1], "%D")
        if current_entry_date == date
          entry_found = true
        elsif !entry_found && current_entry_date < date
          break
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
    #  content of the entry.
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
    file.puts "ENTRYDATE #{date.strftime("%D")}"
    file.puts content
    file.puts "ENTRYEND"
  end

  #write_file - Write file1 to file2
  #  Inputs:
  #    file1 - File we are are writing
  #    file2 - File we are writing to
  #  Returns:
  #    None
  def write_file(file1, file2)
    file1.each do |line|
      file2.puts line
    end
  end

  #cleanup - Cleans up files
  #  Inputs:
  #    files - array of files to cleanup
  #  Returns:
  #    None
  def cleanup(*files)
    files.each do |f|
      f.close
      File.delete f.path
    end
  end
end

#usage - Prints applications usage message
#  Inputs:
#    None
#  Returns:
#    None
def usage
  puts "Usage: journal action <date> <filter>"
  puts "Actions:"
  puts "  new - Create a new journal entry for today."
  puts "  edit - Edit an entry for the given date in the format MM/DD/YY."
  puts "  delete - Delete entry for the given date in the format MM/DD/YY."
  puts "  list - Lists all entries unless given a filter. Filter is in the"
  puts "         format MM/DD/YY with * being used as a wilcard: 01/*/14"
  puts "         to list all entries from January 2014."
  puts "  help - Prints this help message."
  exit
end

#valid_date? - Checks that the date given but the user is valid
#  Inputs:
#    date - the string to be checked for a valid date
#  Returns:
#    True if the string is a valid date
#    False if the string is empty or invalid
def valid_date?(date)
  #Make sure we were passed something and that it is in the correct format
  if !date.nil? && !/(\d{2}\/\d{2}\/\d{2})/.match(ARGV[1]).nil?
    #Split the date and test to ensure it is valid, if so return true
    date_parts = date.split "/"
    if Date.valid_date?(date_parts[2].to_i,
                        date_parts[0].to_i,
                        date_parts[1].to_i)
      return true
    end
  end
 
  #If we failed any of the above, indicating a bad date, then return false
  return false
end

#query_user - Loops asking user the given question until a valid answer is given
#  Inputs:
#    question - Question to ask the user
#    answers - Valid answers to the question
#  Returns:
#    The answer given by the user
def query_user(question, *answers)
  #Initialize answer to nothing for the save of the loop
  answer = ""

  #While we aren't given a valid answer, print the question and get the answer
  while !answers.include? answer
    print "#{question} [#{answers.join("/")}] "
    answer = STDIN.gets.chomp.downcase
  end

  #return the answer we were given by the user
  return answer
end

#Create a new journal object fo the journal.txt file
journal = Journal.new "journal.txt"

#Check to see what action was given as the first argument
case ARGV[0]
  #Both "new" and no action given signify a new entry
  when "new", nil
    journal.new_entry
  when "edit"
    #Check for a valid date and edit if we have one
    if valid_date? ARGV[1]
      journal.edit_entry Date.strptime(ARGV[1], "%D")
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
    end
  when "delete"
    if valid_date? ARGV[1]
      journal.delete_entry Date.strptime(ARGV[1], "%D")
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
    end
  when "list"
    journal.list_entries ARGV[1]
  when "help"
    #This simply prints the usage message, this is so I can add a unknown
    #  action line below
    usage
  else
    #If an unrecognized action, print usage
    puts "Unknown action: #{ARGV[0]}"
    usage
end

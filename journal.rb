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
  def initialize(journal_file, editor)
    #Just set the filename and editor for the object
    @filename = journal_file
    @editor = editor

    #Check for the existance of the journal file and create if it doesn't exist
    #  and user wants to create it, otherwise abort
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
        abort "Cannot work without a journal file, exiting."
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
      if read_date(date.split(" ")[1]) == todays_date
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
    system "#{@editor} #{tmp_filename}"

    #If the user just quit their editor without saving anything, return gracefully
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
      puts "No entry for #{write_date(date)}"
      cleanup(before_file, after_file, tmp_file, new_file)
      return
    end

    #Place the entry into the tmpfile and open it up for the user to edit
    tmp_file.print entry
    tmp_file.close
    system "#{@editor} #{tmp_filename}"

    #Get the edited contents
    entry_contents = ""
    tmp_file = File.open(tmp_filename, "r")
    tmp_file.each do |line|
      entry_contents += line
    end

    #If the user emptied the file, that is essentially a delete
    if entry_contents.empty?
      #Close out the files and clean everything up
      cleanup(before_file, after_file, tmp_file, new_file)

      #Ask if they want to delete the entry instead, otherwise, we won't edit 
      #  the entry
      puts "This would create an empty journal entry."
      question = "Would you like to delete the entry?"
      if query_user(question, "y", "n") == "n"
        puts "Leaving the entry as is."
      else
        delete_entry date
      end
      return
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

    #If we didn't find an entry, return gracefully
    if !entry
      puts "No entry for #{write_date(date)}"
      cleanup(before_file, after_file, new_file)
      return
    else
      #Make sure user wants to delete the entry, if not, return gracefully
      question = "Are you sure you want to delete the entry for #{write_date(date)}?"
      if query_user(question, "y", "n") == "n"
        cleanup(before_file, after_file, new_file)
        return
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

    #Build default regex
    filter_regex = /.*/

    #If we were given a filter, process it and build regex
    if !filter.nil?
      filter = filter.sub("/", "\\/")
      filter.sub!("*", "\\d")
      filter_regex = /#{filter}/
    end

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

  #view_entry - Print entry to terminal 
  #  Inputs:
  #    date - Date to display
  #  Returns:
  #    None
  def view_entry(date)
    #Find the entry putting before and after file into /dev/null since we don't
    #  need or want that data in this case.
    entry = find_entry(File.new("/dev/null", "w"), 
                        File.new("/dev/null", "w"), 
                        date)

    #If the entry was not found, tell the user
    if !entry
      puts "No entry for #{write_date(date)}"
    else
      #Print the entry to stdout with the date
      puts "Date: #{write_date(date)}"
      puts ""
      puts entry
    end
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
        current_entry_date = read_date line.split(" ")[1]
        if current_entry_date == date
          entry_found = true
        elsif !entry_found && current_entry_date < date
          #Break the search if we have surpassed the date we want
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
    file.puts "ENTRYDATE #{write_date(date)}"
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
  puts "  view - Prints the entry for the given date to the terminal."
  puts "  help - Prints this help message."
  return
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

#read_date - Reads date using %D format
#  Inputs:
#    date - Date to read
#  Returns:
#    None
def read_date(date)
  return Date.strptime(date, "%D")
end

#write_date - Writes date using %D format
#  Inputs:
#    date - Date to write
#  Returns:
#    None
def write_date(date) 
  return date.strftime("%D")
end

#Default values for the .journalrc config options
editor = "vim"
filedir = ENV["HOME"]

#Check to see if the config file exists, if it doesn't make it, if it does get
#  the configuration options
if !File.exists? "#{ENV["HOME"]}/.journalrc"
  puts "Default settings:"
  puts "EDITOR=#{editor}"
  puts "FILEDIR=#{filedir}"
  #Ask the user if they want to create .journalrc
  question = "You do not have ~/.journalrc, would you like to create one?"
  if query_user(question, "y", "n") == "n"
    #Just go on with the defaults set above if no
    puts "Using default settings"
  else
    #Create the file using the defaults from above and notify the user
    File.open("#{ENV["HOME"]}/.journalrc", "w") do |f|
      f.puts "EDITOR=#{editor}"
      f.puts "FILEDIR=#{filedir}"
    end
    puts "Created ~/.journalrc using default values"
  end
else
  #Open the config file
  f = File.open("#{ENV["HOME"]}/.journalrc", "r")
  #Loop through the config file
  f.each do |line|
    #Get the setting and it's value, this would break if for some reason there
    #  is an = in the value. This will be documented.
    setting, value = line.chomp.split("=")
    #Use the case statement to set the config variables
    case setting
      when "EDITOR"
        editor = value
      when "FILEDIR"
        filedir = value
      else
        #If we are here, they gave some unsupported option, let them know
        puts "Unknown setting in .journalrc, ignoring: #{setting}"
    end
  end
end

#Create a new journal object for the journal.txt file and pass the editor along
journal = Journal.new("#{filedir}/journal.txt", editor)

#Check to see what action was given as the first argument
case ARGV[0]
  #Both "new" and no action given signify a new entry
  when "new", nil
    journal.new_entry
  when "edit"
    #Check for a valid date and edit if we have one
    if valid_date? ARGV[1]
      journal.edit_entry read_date(ARGV[1])
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
    end
  when "delete"
    if valid_date? ARGV[1]
      journal.delete_entry read_date(ARGV[1])
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
    end
  when "list"
    journal.list_entries ARGV[1]
  when "view"
    if valid_date? ARGV[1]
      journal.view_entry read_date(ARGV[1])
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
    end
  when "help"
    #This simply prints the usage message, this is so I can add a unknown
    #  action line below
    usage
  else
    #If an unrecognized action, print usage
    puts "Unknown action: #{ARGV[0]}"
    usage
end

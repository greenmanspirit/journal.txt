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
    @filename = journal_file
    @now = Time.now
  end

  def new_entry
    #Get the new journal entry
    tmp_filename = "/tmp/journal_#{ENV['USER']}_#{@now.strftime('%s')}.txt"
    system "vim #{tmp_filename}"

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

  def edit_entry(date)
    before_file = File.new("#{@filename}.before", 'w+')
    after_file = File.new("#{@filename}.after", 'w+')
    tmp_filename = "/tmp/journal_#{ENV['USER']}_#{@now.strftime('%s')}.txt"
    entry = find_entry(before_file, after_file, date) || "No entry for #{date}"
    tmp_file = File.new(tmp_filename, 'w+')
    tmp_file.print entry
    tmp_file.close
    system "vim #{tmp_filename}"
    entry_contents = ""
    File.open tmp_filename do |t|
      t.each do |line|
         entry_contents += line
      end
    end
    new_file = File.new("#{@filename}.new", 'w+')
    before_file.each do |line|
      new_file.print line
    end
    write_entry(new_file, entry_contents, date)
    after_file.each do |line|
      new_file.print line
    end

    before_file.close
    after_file.close
    File.delete tmp_filename
    File.delete "#{@filename}.before"
    File.delete "#{@filename}.after"
    File.rename("#{@filename}.new", @filename)
  end


  private

  def find_entry(before_file, after_file, date)
    entry_found = false
    entry_complete = false
    current_entry = ""
    current_entry_date = ""
    requested_entry = ""

    file = File.new(@filename, 'r')

    file.each do |line|
      if line == "STARTENTRY\n"
        current_entry = ""
        next
      elsif line == "ENDENTRY\n"
        if !entry_found
          write_entry(before_file, current_entry, current_entry_date)
        elsif entry_found && !entry_complete
          requested_entry = current_entry
          entry_complete = true
        elsif entry_complete
          write_entry(after_file, current_entry, current_entry_date)
        end
      elsif line.start_with?("DATE ")
        current_entry_date = line.split(' ')[1]
        if current_entry_date == date
          entry_found = true
        end
        next
      end

      current_entry += line
    end

    file.close
    before_file.rewind
    after_file.rewind

    if(requested_entry == "")
      return false
    else
      return requested_entry
    end
  end

  def write_entry(file, content, date)
    file.puts "STARTENTRY"
    file.puts "DATE #{date}"
    file.puts content
    file.puts "ENDENTRY"
  end
end

def usage
  puts "Usage: journal action <date>"
  puts "Actions:"
  puts "  new - Create a new journal entry for today"
  puts "  edit - Edit an entry for the given date in format MM/DD/YY"
  exit
end

journal = Journal.new 'journal.txt'

case ARGV[0]
  when "new", nil
    journal.new_entry
  when "edit"
    require 'date'
    if !ARGV[1].nil? &&
        !/(\d{2}\/\d{2}\/\d{2})/.match(ARGV[1]).nil? &&
        Date.valid_date?(Integer(ARGV[1][6..7]),
                          Integer(ARGV[1][0..1]),
                          Integer(ARGV[1][3..4]))
      journal.edit_entry ARGV[1]
    else
      puts "Invalid Date - Please enter date in the format MM/DD/YY"
      exit
    end
  else
    usage
end

require 'rubygems'
require 'active_record'
require 'yaml'
require 'CSV'
require 'debugger'
require 'date'

def removeComments(file_path)
  line_arr = File.readlines(file_path)
  lines_to_keep
  line_arr.each do |line|
    if line =~ /^com/
      
    end
  end
  File.open(file_path, 'w') do |f|
    line_arr.each { |line| f.puts(line) }
  end
  
end
# this iterates over every file/directory in raw_data (which we know is a directory)
Dir.entries('./raw_data').each do |dir|
  # grabs all the files (.ROS, .EVA, .EVN) in the subdirectory
  file_names = Dir.entries("./raw_data/#{dir}")
  
  # 
  file_names.each do |file_name|
    if file_name =~ /.*\.EV(A|N)/
      removeComments("./raw_data/#{dir}/#{file_name}")
    end
  end
end



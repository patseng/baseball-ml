require 'rubygems'
require 'active_record'
require 'yaml'
require 'CSV'
require 'debugger'

require './models/player.rb'


dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

def parseROS(file_path)
  # this opens the csv at the file path at iterates over the rows
  CSV.foreach(file_path) do |row|
    player_id = row[0]
    name = "#{row[1]}, #{row[2]}" #last name, first name

    hitting_style = row[4]
    hitting_enum = 0
    case hitting_style
    when 'L'
      hitting_enum = -1
    when 'R'
      hitting_enum = 1
    else
    end
    
    # find_by_some_attribute is a nice feature of ActiveRecord::Base
    if !Player.find_by_player_id(player_id)
      player = Player.new(:player_id => player_id, 
                          :batting_style => hitting_enum,
                           :player_name => name)
      player.save
    end
  end
end

# this iterates over every file/directory in raw_data (which we know is a directory)
Dir.entries('./raw_data').each do |dir|
  # grabs all the files (.ROS, .EVA, .EVN) in the subdirectory
  file_names = Dir.entries("./raw_data/#{dir}")
  
  # 
  file_names.each do |file_name|
    if file_name =~ /.*\.ROS/
      parseROS("./raw_data/#{dir}/#{file_name}")
    end
  end
end



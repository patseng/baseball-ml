require 'rubygems'
require 'active_record'
require 'yaml'
require 'CSV'
require 'debugger'
require 'date'

require './models/game.rb'


dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

def parseEVA(file_path)
  # this opens the csv at the file path at iterates over the rows
  current_game = nil
  CSV.foreach(file_path) do |row|
    delimeter = row[0]
    case delimeter
    when 'id'
      debugger
      if current_game
        current_game.save
      end
      current_game = Game.new
    when 'info'
      second_token = row[1]
      third_token = row[2]
      case second_token
      when 'visteam'
        # debugger
        # current_game.away_team = third_token
      when 'hometeam'
        current_game.home_team = third_token.to_s       
      when 'daynight'
        # current_game.day_game = if third_token == "day" then true else false end
      when 'date'
        # current_game.game_date = DateTime.parse(third_token)
      when 'usedh'
        # current_game.used_designated_hitter = if third_token == "true" then true else false end
      when 'temp'
        # current_game.temperature = third_token.to_i
      when 'windspeed'
        # current_game.wind_speed = third_token.to_i
      when 'number'
        # current_game.game_number = third_token.to_i
      else
      end
    else
    end
  end

  current_game.save if current_game
end

# this iterates over every file/directory in raw_data (which we know is a directory)
Dir.entries('./raw_data').each do |dir|
  # grabs all the files (.ROS, .EVA, .EVN) in the subdirectory
  file_names = Dir.entries("./raw_data/#{dir}")
  
  # 
  file_names.each do |file_name|
    if file_name =~ /.*\.EV(A|N)/
      parseEVA("./raw_data/#{dir}/#{file_name}")
    end
  end
end



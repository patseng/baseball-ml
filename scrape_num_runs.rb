require 'rubygems'
require 'active_record'
require 'yaml'
require 'CSV'
require 'debugger'
require 'date'

require './models/game.rb'
require './models/player.rb'
require './models/performance.rb'

require './teamMap.rb'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

def parseGameLog(file_path)
  # this opens the csv at the file path at iterates over the rows
  CSV.foreach(file_path) do |row|
    home_runs = row[10].to_i
    away_runs = row[9].to_i
    
    date = DateTime.parse(row[0])
    number = row[1]

    if number == 'A'
      number = '1'
    elsif number == 'B'
      number = '2'
    end

    number = number.to_i

    game = Game.find_by_game_date_and_game_number(date, number)

    game.home_team_runs = home_runs
    game.away_team_runs = away_runs

    game.home_team_won = (home_runs > away_runs)

    game.save
  end
end

# this iterates over every file/directory in raw_data (which we know is a directory)
Dir.entries('./raw_data/game_logs').each do |entry|
  if entry =~ /.*\.TXT/
    parseGameLog("./raw_data/game_logs/#{entry}")
  end
end
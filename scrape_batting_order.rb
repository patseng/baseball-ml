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
    home_team = TeamMap.teamNamesToInt[row[6]]
    
    date = DateTime.parse(row[0])
    number = row[1]

    if number == 'A'
      number = '1'
    elsif number == 'B'
      number = '2'
    end

    number = number.to_i

    game = Game.find_by_home_team_and_game_date_and_game_number(home_team, date, number)

    game.home_batting_spot_1 = row[105]
    game.home_batting_spot_2 = row[108]
    game.home_batting_spot_3 = row[111]
    game.home_batting_spot_4 = row[114]
    game.home_batting_spot_5 = row[117]
    game.home_batting_spot_6 = row[120]
    game.home_batting_spot_7 = row[123]
    game.home_batting_spot_8 = row[126]
    game.home_batting_spot_9 = row[129]
    
    game.away_batting_spot_1 = row[132]
    game.away_batting_spot_2 = row[135]
    game.away_batting_spot_3 = row[138]
    game.away_batting_spot_4 = row[141]
    game.away_batting_spot_5 = row[144]
    game.away_batting_spot_6 = row[147]
    game.away_batting_spot_7 = row[150]
    game.away_batting_spot_8 = row[153]
    game.away_batting_spot_9 = row[156]

    game.save
  end
end

# this iterates over every file/directory in raw_data (which we know is a directory)
Dir.entries('./raw_data/game_logs').each do |entry|
  if entry =~ /.*\.TXT/
    parseGameLog("./raw_data/game_logs/#{entry}")
  end
end
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

n = 3
m = 0

File.open("temp", "w") do |file|
  Game.all.each do |game|
    # get the past 3 games
    home_faceoffs = Game.where("home_team = ? and away_team = ?", game.home_team, game.away_team).order("game_date desc").limit(3)
    away_faceoffs = Game.where("home_team = ? and away_team = ?", game.away_team, game.home_team).order("game_date desc").limit(3)
    past_games = home_faceoffs.concat(away_faceoffs)
    past_games = past_games.sort {|game1, game2| game2.game_date <=> game1.game_date }

    if past_games.size < 3
      next
    end

    past_games = past_games[0..2]

    # compute past 3 run differntials where
    run_differentials = []
    past_games.each do |past_game| 
      if past_game.home_team == game.home_team
        run_differentials << past_game.home_team_runs - past_game.away_team_runs
      else 
        run_differentials << past_game.away_team_runs - past_game.home_team_runs      
      end
    end

    # tie goes to home team
    if game.home_team_runs >= game.away_team_runs then y = 1 else y = -1 end

    # write a row in a file
    file.write("#{y} #{run_differentials.join(' ')}\n")

    m += 1
  end
end


File.open("MATRIX.TRAIN", "w") do |file|
  file.write("#{m} #{n}")
  File.readlines('temp').each do |line|
    file.write(line)
  end
end

File.delete('temp')


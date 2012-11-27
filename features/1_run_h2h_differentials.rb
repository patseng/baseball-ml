require 'rubygems'
require 'active_record'
require 'yaml'
require 'CSV'
require 'debugger'
require 'date'
require 'libsvm'

require './models/game.rb'
require './models/player.rb'
require './models/performance.rb'
require './models/feature.rb'

require './teamMap.rb'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# =============================================================================
# helper function
# creates head to head run differential
# =============================================================================

def addFeaturesAndLabel(home_team, away_team, earliest_date, latest_date)
  home_faceoffs = Game.where("home_team = ? and away_team = ? and game_date > ? and game_date <= ?", home_team, away_team, earliest_date, latest_date).order("game_date desc")
  away_faceoffs = Game.where("home_team = ? and away_team = ? and game_date > ? and game_date <= ?", away_team, home_team, earliest_date, latest_date).order("game_date desc")
  past_games = home_faceoffs.concat(away_faceoffs)
  past_games = past_games.sort {|game1, game2| game1.game_date <=> game2.game_date }

  if past_games.size < 3
    return
  end

  run_differentials = [0, 0, 0]

  past_games.each_with_index do |past_game, index|
    feature_set = Feature.new

    feature_set.game_id = past_game.id
    feature_set.home_team_won = past_game.home_team_won

    if past_game.home_team == home_team.to_s
      feature_set.h2h_diff_1 = run_differentials[2]
      feature_set.h2h_diff_2 = run_differentials[1]
      feature_set.h2h_diff_3 = run_differentials[0]

      run_differentials << past_game.home_team_runs - past_game.away_team_runs
    else 
      feature_set.h2h_diff_1 = -1*run_differentials[2]
      feature_set.h2h_diff_2 = -1*run_differentials[1]
      feature_set.h2h_diff_3 = -1*run_differentials[0]

      run_differentials << past_game.away_team_runs - past_game.home_team_runs      
    end

    feature_set.save

    if run_differentials.size > 3
      run_differentials.shift
    end
  end
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
(1 .. 30).each do |i|
  (i + 1 .. 30).each do |j|
    addFeaturesAndLabel(i, j, DateTime.parse("20010101"), DateTime.parse("20110101"))
  end
end

puts "generating testing set...."
(1 .. 30).each do |i|
  (i + 1 .. 30).each do |j|
    addFeaturesAndLabel(i, j, DateTime.parse("20110101"), DateTime.parse("20120101"))
  end
end

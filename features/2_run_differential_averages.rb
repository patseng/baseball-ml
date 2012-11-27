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
# These are general run diffferentials not head to head
# =============================================================================

# Adding last 1, 2, 5, 10, and 20 games
def addFeaturesAndLabel(team, earliest_date, latest_date, examples, labels)
  home_faceoffs = Game.where("home_team = ? and game_date > ? and game_date <= ?", team, earliest_date, latest_date).order("game_date desc")
  away_faceoffs = Game.where("away_team = ? and game_date > ? and game_date <= ?", team, earliest_date, latest_date).order("game_date desc")
  past_games = home_faceoffs.concat(away_faceoffs)
  past_games = past_games.sort {|game1, game2| game1.game_date <=> game2.game_date }

  if past_games.size < 21
    return
  end

  run_differentials_1 = [0]
  run_differentials_2 = [0, 0]
  run_differentials_5 = [0, 0, 0, 0, 0]
  run_differentials_10 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  run_differentials_20 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  past_games.each_with_index do |past_game, index|
    feature_set = Feature.find_by_game_id(past_game.id)

    if past_game.home_team == team.to_s
      feature_set.run_differentials_1 = run_differentials_1.reduce(:+).to_f
      feature_set.run_differentials_2 = run_differentials_2.reduce(:+).to_f / 2
      feature_set.run_differentials_5 = run_differentials_5.reduce(:+).to_f / 5
      feature_set.run_differentials_10 = run_differentials_10.reduce(:+).to_f / 10
      feature_set.run_differentials_20 = run_differentials_20.reduce(:+).to_f / 20

      run_to_add = past_game.home_team_runs - past_game.away_team_runs
    else
      feature_set.opp_differentials_1 = run_differentials_1.reduce(:+).to_f
      feature_set.opp_differentials_2 = run_differentials_2.reduce(:+).to_f / 2
      feature_set.opp_differentials_5 = run_differentials_5.reduce(:+).to_f / 5
      feature_set.opp_differentials_10 = run_differentials_10.reduce(:+).to_f / 10
      feature_set.opp_differentials_20 = run_differentials_20.reduce(:+).to_f / 20

      run_to_add = past_game.away_team_runs - past_game.home_team_runs      
    end

    feature_set.save

    run_differentials_1 << run_to_add
    run_differentials_2 << run_to_add
    run_differentials_5 << run_to_add
    run_differentials_10 << run_to_add
    run_differentials_20 << run_to_add
    
    run_differentials_1.shift
    run_differentials_2.shift
    run_differentials_5.shift
    run_differentials_10.shift
    run_differentials_20.shift
  end
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []

(1 .. 30).each do |i|
  addFeaturesAndLabel(i, DateTime.parse("20010101"), DateTime.parse("20110101"), training_examples, training_labels)
end

puts "generating testing set...."
testing_examples = []
testing_labels = []

(1 .. 30).each do |i|
  addFeaturesAndLabel(i, DateTime.parse("20110101"), DateTime.parse("20120101"), testing_examples, testing_labels)
end

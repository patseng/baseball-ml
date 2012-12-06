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
# =============================================================================

def addFeaturesAndLabel(earliest_date, latest_date, examples, labels)
  all_games = Game.where("game_date > ? AND game_date < ?", earliest_date, latest_date)

  all_games.each do |game|
    feature = Feature.find_by_game_id(game.id)
    if feature == nil
      feature = Feature.new
      feature.game_id = game.id
      feature.home_team_won = game.home_team_won
      feature.save
    end

    feature_set = []

    # Add in individual features
    feature_set << feature.h2h_diff_1
    feature_set << feature.h2h_diff_2
    feature_set << feature.h2h_diff_3
    
#=begin
    feature_set << feature.run_differentials_1
    feature_set << feature.opp_differentials_1
    feature_set << feature.run_differentials_2
    feature_set << feature.opp_differentials_2
    feature_set << feature.run_differentials_5
    feature_set << feature.opp_differentials_5
    feature_set << feature.run_differentials_10
    feature_set << feature.opp_differentials_10
    feature_set << feature.run_differentials_20
    feature_set << feature.opp_differentials_20

    feature_set << feature.win_differentials_1
    feature_set << feature.opp_win_differentials_1
    feature_set << feature.win_differentials_2
    feature_set << feature.opp_win_differentials_2
    feature_set << feature.win_differentials_5
    feature_set << feature.opp_win_differentials_5
    feature_set << feature.win_differentials_10
    feature_set << feature.opp_win_differentials_10
    feature_set << feature.win_differentials_20
    feature_set << feature.opp_win_differentials_20
#=end

=begin
    # Add in the differences between features. Could be preferable?
    feature_set << feature.run_differentials_1 - feature.opp_differentials_1
    feature_set << feature.run_differentials_2 - feature.opp_differentials_2
    feature_set << feature.run_differentials_5 - feature.opp_differentials_5
    feature_set << feature.run_differentials_10 - feature.opp_differentials_10
    feature_set << feature.run_differentials_20 - feature.opp_differentials_20
    
    feature_set << feature.win_differentials_1 - feature.opp_win_differentials_1
    feature_set << feature.win_differentials_2 - feature.opp_win_differentials_2
    feature_set << feature.win_differentials_5 - feature.opp_win_differentials_5
    feature_set << feature.win_differentials_10 - feature.opp_win_differentials_10
    feature_set << feature.win_differentials_20 - feature.opp_win_differentials_20
=end

#=begin
    feature_set << feature.home_batting_spot_1_walks_last_1_game
    feature_set << feature.home_batting_spot_2_walks_last_1_game
    feature_set << feature.home_batting_spot_3_walks_last_1_game
    feature_set << feature.home_batting_spot_4_walks_last_1_game
    feature_set << feature.home_batting_spot_5_walks_last_1_game
    feature_set << feature.home_batting_spot_6_walks_last_1_game
    feature_set << feature.home_batting_spot_7_walks_last_1_game
    feature_set << feature.home_batting_spot_8_walks_last_1_game
    feature_set << feature.home_batting_spot_9_walks_last_1_game

    feature_set << feature.away_batting_spot_1_walks_last_1_game
    feature_set << feature.away_batting_spot_2_walks_last_1_game
    feature_set << feature.away_batting_spot_3_walks_last_1_game
    feature_set << feature.away_batting_spot_4_walks_last_1_game
    feature_set << feature.away_batting_spot_5_walks_last_1_game
    feature_set << feature.away_batting_spot_6_walks_last_1_game
    feature_set << feature.away_batting_spot_7_walks_last_1_game
    feature_set << feature.away_batting_spot_8_walks_last_1_game
    feature_set << feature.away_batting_spot_9_walks_last_1_game

    feature_set << feature.home_batting_spot_1_walks_last_2_games
    feature_set << feature.home_batting_spot_2_walks_last_2_games
    feature_set << feature.home_batting_spot_3_walks_last_2_games
    feature_set << feature.home_batting_spot_4_walks_last_2_games
    feature_set << feature.home_batting_spot_5_walks_last_2_games
    feature_set << feature.home_batting_spot_6_walks_last_2_games
    feature_set << feature.home_batting_spot_7_walks_last_2_games
    feature_set << feature.home_batting_spot_8_walks_last_2_games
    feature_set << feature.home_batting_spot_9_walks_last_2_games

    feature_set << feature.away_batting_spot_1_walks_last_2_games
    feature_set << feature.away_batting_spot_2_walks_last_2_games
    feature_set << feature.away_batting_spot_3_walks_last_2_games
    feature_set << feature.away_batting_spot_4_walks_last_2_games
    feature_set << feature.away_batting_spot_5_walks_last_2_games
    feature_set << feature.away_batting_spot_6_walks_last_2_games
    feature_set << feature.away_batting_spot_7_walks_last_2_games
    feature_set << feature.away_batting_spot_8_walks_last_2_games
    feature_set << feature.away_batting_spot_9_walks_last_2_games

    feature_set << feature.home_batting_spot_1_walks_last_5_games
    feature_set << feature.home_batting_spot_2_walks_last_5_games
    feature_set << feature.home_batting_spot_3_walks_last_5_games
    feature_set << feature.home_batting_spot_4_walks_last_5_games
    feature_set << feature.home_batting_spot_5_walks_last_5_games
    feature_set << feature.home_batting_spot_6_walks_last_5_games
    feature_set << feature.home_batting_spot_7_walks_last_5_games
    feature_set << feature.home_batting_spot_8_walks_last_5_games
    feature_set << feature.home_batting_spot_9_walks_last_5_games

    feature_set << feature.away_batting_spot_1_walks_last_5_games
    feature_set << feature.away_batting_spot_2_walks_last_5_games
    feature_set << feature.away_batting_spot_3_walks_last_5_games
    feature_set << feature.away_batting_spot_4_walks_last_5_games
    feature_set << feature.away_batting_spot_5_walks_last_5_games
    feature_set << feature.away_batting_spot_6_walks_last_5_games
    feature_set << feature.away_batting_spot_7_walks_last_5_games
    feature_set << feature.away_batting_spot_8_walks_last_5_games
    feature_set << feature.away_batting_spot_9_walks_last_5_games

    feature_set << feature.home_batting_spot_1_walks_last_10_games
    feature_set << feature.home_batting_spot_2_walks_last_10_games
    feature_set << feature.home_batting_spot_3_walks_last_10_games
    feature_set << feature.home_batting_spot_4_walks_last_10_games
    feature_set << feature.home_batting_spot_5_walks_last_10_games
    feature_set << feature.home_batting_spot_6_walks_last_10_games
    feature_set << feature.home_batting_spot_7_walks_last_10_games
    feature_set << feature.home_batting_spot_8_walks_last_10_games
    feature_set << feature.home_batting_spot_9_walks_last_10_games

    feature_set << feature.away_batting_spot_1_walks_last_10_games
    feature_set << feature.away_batting_spot_2_walks_last_10_games
    feature_set << feature.away_batting_spot_3_walks_last_10_games
    feature_set << feature.away_batting_spot_4_walks_last_10_games
    feature_set << feature.away_batting_spot_5_walks_last_10_games
    feature_set << feature.away_batting_spot_6_walks_last_10_games
    feature_set << feature.away_batting_spot_7_walks_last_10_games
    feature_set << feature.away_batting_spot_8_walks_last_10_games
    feature_set << feature.away_batting_spot_9_walks_last_10_games

    feature_set << feature.home_batting_spot_1_walks_last_20_games
    feature_set << feature.home_batting_spot_2_walks_last_20_games
    feature_set << feature.home_batting_spot_3_walks_last_20_games
    feature_set << feature.home_batting_spot_4_walks_last_20_games
    feature_set << feature.home_batting_spot_5_walks_last_20_games
    feature_set << feature.home_batting_spot_6_walks_last_20_games
    feature_set << feature.home_batting_spot_7_walks_last_20_games
    feature_set << feature.home_batting_spot_8_walks_last_20_games
    feature_set << feature.home_batting_spot_9_walks_last_20_games

    feature_set << feature.away_batting_spot_1_walks_last_20_games
    feature_set << feature.away_batting_spot_2_walks_last_20_games
    feature_set << feature.away_batting_spot_3_walks_last_20_games
    feature_set << feature.away_batting_spot_4_walks_last_20_games
    feature_set << feature.away_batting_spot_5_walks_last_20_games
    feature_set << feature.away_batting_spot_6_walks_last_20_games
    feature_set << feature.away_batting_spot_7_walks_last_20_games
    feature_set << feature.away_batting_spot_8_walks_last_20_games
    feature_set << feature.away_batting_spot_9_walks_last_20_games

    feature_set << feature.home_batting_spot_1_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_2_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_3_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_4_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_5_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_6_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_7_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_8_batting_percentage_last_1_game
    feature_set << feature.home_batting_spot_9_batting_percentage_last_1_game

    feature_set << feature.away_batting_spot_1_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_2_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_3_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_4_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_5_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_6_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_7_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_8_batting_percentage_last_1_game
    feature_set << feature.away_batting_spot_9_batting_percentage_last_1_game

    feature_set << feature.home_batting_spot_1_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_2_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_3_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_4_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_5_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_6_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_7_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_8_batting_percentage_last_2_games
    feature_set << feature.home_batting_spot_9_batting_percentage_last_2_games

    feature_set << feature.away_batting_spot_1_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_2_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_3_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_4_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_5_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_6_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_7_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_8_batting_percentage_last_2_games
    feature_set << feature.away_batting_spot_9_batting_percentage_last_2_games

    feature_set << feature.home_batting_spot_1_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_2_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_3_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_4_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_5_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_6_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_7_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_8_batting_percentage_last_5_games
    feature_set << feature.home_batting_spot_9_batting_percentage_last_5_games

    feature_set << feature.away_batting_spot_1_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_2_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_3_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_4_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_5_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_6_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_7_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_8_batting_percentage_last_5_games
    feature_set << feature.away_batting_spot_9_batting_percentage_last_5_games

    feature_set << feature.home_batting_spot_1_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_2_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_3_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_4_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_5_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_6_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_7_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_8_batting_percentage_last_10_games
    feature_set << feature.home_batting_spot_9_batting_percentage_last_10_games

    feature_set << feature.away_batting_spot_1_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_2_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_3_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_4_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_5_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_6_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_7_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_8_batting_percentage_last_10_games
    feature_set << feature.away_batting_spot_9_batting_percentage_last_10_games

    feature_set << feature.home_batting_spot_1_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_2_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_3_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_4_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_5_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_6_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_7_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_8_batting_percentage_last_20_games
    feature_set << feature.home_batting_spot_9_batting_percentage_last_20_games

    feature_set << feature.away_batting_spot_1_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_2_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_3_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_4_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_5_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_6_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_7_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_8_batting_percentage_last_20_games
    feature_set << feature.away_batting_spot_9_batting_percentage_last_20_games

    feature_set << feature.home_batting_spot_1_OPS_last_1_game
    feature_set << feature.home_batting_spot_2_OPS_last_1_game
    feature_set << feature.home_batting_spot_3_OPS_last_1_game
    feature_set << feature.home_batting_spot_4_OPS_last_1_game
    feature_set << feature.home_batting_spot_5_OPS_last_1_game
    feature_set << feature.home_batting_spot_6_OPS_last_1_game
    feature_set << feature.home_batting_spot_7_OPS_last_1_game
    feature_set << feature.home_batting_spot_8_OPS_last_1_game
    feature_set << feature.home_batting_spot_9_OPS_last_1_game

    feature_set << feature.away_batting_spot_1_OPS_last_1_game
    feature_set << feature.away_batting_spot_2_OPS_last_1_game
    feature_set << feature.away_batting_spot_3_OPS_last_1_game
    feature_set << feature.away_batting_spot_4_OPS_last_1_game
    feature_set << feature.away_batting_spot_5_OPS_last_1_game
    feature_set << feature.away_batting_spot_6_OPS_last_1_game
    feature_set << feature.away_batting_spot_7_OPS_last_1_game
    feature_set << feature.away_batting_spot_8_OPS_last_1_game
    feature_set << feature.away_batting_spot_9_OPS_last_1_game

    feature_set << feature.home_batting_spot_1_OPS_last_2_games
    feature_set << feature.home_batting_spot_2_OPS_last_2_games
    feature_set << feature.home_batting_spot_3_OPS_last_2_games
    feature_set << feature.home_batting_spot_4_OPS_last_2_games
    feature_set << feature.home_batting_spot_5_OPS_last_2_games
    feature_set << feature.home_batting_spot_6_OPS_last_2_games
    feature_set << feature.home_batting_spot_7_OPS_last_2_games
    feature_set << feature.home_batting_spot_8_OPS_last_2_games
    feature_set << feature.home_batting_spot_9_OPS_last_2_games

    feature_set << feature.away_batting_spot_1_OPS_last_2_games
    feature_set << feature.away_batting_spot_2_OPS_last_2_games
    feature_set << feature.away_batting_spot_3_OPS_last_2_games
    feature_set << feature.away_batting_spot_4_OPS_last_2_games
    feature_set << feature.away_batting_spot_5_OPS_last_2_games
    feature_set << feature.away_batting_spot_6_OPS_last_2_games
    feature_set << feature.away_batting_spot_7_OPS_last_2_games
    feature_set << feature.away_batting_spot_8_OPS_last_2_games
    feature_set << feature.away_batting_spot_9_OPS_last_2_games

    feature_set << feature.home_batting_spot_1_OPS_last_5_games
    feature_set << feature.home_batting_spot_2_OPS_last_5_games
    feature_set << feature.home_batting_spot_3_OPS_last_5_games
    feature_set << feature.home_batting_spot_4_OPS_last_5_games
    feature_set << feature.home_batting_spot_5_OPS_last_5_games
    feature_set << feature.home_batting_spot_6_OPS_last_5_games
    feature_set << feature.home_batting_spot_7_OPS_last_5_games
    feature_set << feature.home_batting_spot_8_OPS_last_5_games
    feature_set << feature.home_batting_spot_9_OPS_last_5_games

    feature_set << feature.away_batting_spot_1_OPS_last_5_games
    feature_set << feature.away_batting_spot_2_OPS_last_5_games
    feature_set << feature.away_batting_spot_3_OPS_last_5_games
    feature_set << feature.away_batting_spot_4_OPS_last_5_games
    feature_set << feature.away_batting_spot_5_OPS_last_5_games
    feature_set << feature.away_batting_spot_6_OPS_last_5_games
    feature_set << feature.away_batting_spot_7_OPS_last_5_games
    feature_set << feature.away_batting_spot_8_OPS_last_5_games
    feature_set << feature.away_batting_spot_9_OPS_last_5_games

    feature_set << feature.home_batting_spot_1_OPS_last_10_games
    feature_set << feature.home_batting_spot_2_OPS_last_10_games
    feature_set << feature.home_batting_spot_3_OPS_last_10_games
    feature_set << feature.home_batting_spot_4_OPS_last_10_games
    feature_set << feature.home_batting_spot_5_OPS_last_10_games
    feature_set << feature.home_batting_spot_6_OPS_last_10_games
    feature_set << feature.home_batting_spot_7_OPS_last_10_games
    feature_set << feature.home_batting_spot_8_OPS_last_10_games
    feature_set << feature.home_batting_spot_9_OPS_last_10_games

    feature_set << feature.away_batting_spot_1_OPS_last_10_games
    feature_set << feature.away_batting_spot_2_OPS_last_10_games
    feature_set << feature.away_batting_spot_3_OPS_last_10_games
    feature_set << feature.away_batting_spot_4_OPS_last_10_games
    feature_set << feature.away_batting_spot_5_OPS_last_10_games
    feature_set << feature.away_batting_spot_6_OPS_last_10_games
    feature_set << feature.away_batting_spot_7_OPS_last_10_games
    feature_set << feature.away_batting_spot_8_OPS_last_10_games
    feature_set << feature.away_batting_spot_9_OPS_last_10_games

    feature_set << feature.home_batting_spot_1_OPS_last_20_games
    feature_set << feature.home_batting_spot_2_OPS_last_20_games
    feature_set << feature.home_batting_spot_3_OPS_last_20_games
    feature_set << feature.home_batting_spot_4_OPS_last_20_games
    feature_set << feature.home_batting_spot_5_OPS_last_20_games
    feature_set << feature.home_batting_spot_6_OPS_last_20_games
    feature_set << feature.home_batting_spot_7_OPS_last_20_games
    feature_set << feature.home_batting_spot_8_OPS_last_20_games
    feature_set << feature.home_batting_spot_9_OPS_last_20_games

    feature_set << feature.away_batting_spot_1_OPS_last_20_games
    feature_set << feature.away_batting_spot_2_OPS_last_20_games
    feature_set << feature.away_batting_spot_3_OPS_last_20_games
    feature_set << feature.away_batting_spot_4_OPS_last_20_games
    feature_set << feature.away_batting_spot_5_OPS_last_20_games
    feature_set << feature.away_batting_spot_6_OPS_last_20_games
    feature_set << feature.away_batting_spot_7_OPS_last_20_games
    feature_set << feature.away_batting_spot_8_OPS_last_20_games
    feature_set << feature.away_batting_spot_9_OPS_last_20_games

    feature_set << feature.home_batting_spot_1_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_2_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_3_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_4_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_5_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_6_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_7_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_8_strikeout_rate_last_1_game
    feature_set << feature.home_batting_spot_9_strikeout_rate_last_1_game

    feature_set << feature.away_batting_spot_1_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_2_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_3_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_4_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_5_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_6_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_7_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_8_strikeout_rate_last_1_game
    feature_set << feature.away_batting_spot_9_strikeout_rate_last_1_game

    feature_set << feature.home_batting_spot_1_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_2_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_3_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_4_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_5_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_6_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_7_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_8_strikeout_rate_last_2_games
    feature_set << feature.home_batting_spot_9_strikeout_rate_last_2_games

    feature_set << feature.away_batting_spot_1_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_2_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_3_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_4_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_5_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_6_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_7_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_8_strikeout_rate_last_2_games
    feature_set << feature.away_batting_spot_9_strikeout_rate_last_2_games

    feature_set << feature.home_batting_spot_1_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_2_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_3_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_4_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_5_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_6_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_7_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_8_strikeout_rate_last_5_games
    feature_set << feature.home_batting_spot_9_strikeout_rate_last_5_games

    feature_set << feature.away_batting_spot_1_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_2_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_3_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_4_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_5_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_6_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_7_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_8_strikeout_rate_last_5_games
    feature_set << feature.away_batting_spot_9_strikeout_rate_last_5_games

    feature_set << feature.home_batting_spot_1_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_2_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_3_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_4_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_5_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_6_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_7_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_8_strikeout_rate_last_10_games
    feature_set << feature.home_batting_spot_9_strikeout_rate_last_10_games

    feature_set << feature.away_batting_spot_1_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_2_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_3_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_4_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_5_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_6_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_7_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_8_strikeout_rate_last_10_games
    feature_set << feature.away_batting_spot_9_strikeout_rate_last_10_games

    feature_set << feature.home_batting_spot_1_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_2_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_3_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_4_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_5_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_6_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_7_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_8_strikeout_rate_last_20_games
    feature_set << feature.home_batting_spot_9_strikeout_rate_last_20_games

    feature_set << feature.away_batting_spot_1_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_2_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_3_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_4_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_5_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_6_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_7_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_8_strikeout_rate_last_20_games
    feature_set << feature.away_batting_spot_9_strikeout_rate_last_20_games
    
    feature_set << feature.home_batting_spot_1_walks_per_game_career
    feature_set << feature.home_batting_spot_2_walks_per_game_career
    feature_set << feature.home_batting_spot_3_walks_per_game_career
    feature_set << feature.home_batting_spot_4_walks_per_game_career
    feature_set << feature.home_batting_spot_5_walks_per_game_career
    feature_set << feature.home_batting_spot_6_walks_per_game_career
    feature_set << feature.home_batting_spot_7_walks_per_game_career
    feature_set << feature.home_batting_spot_8_walks_per_game_career
    feature_set << feature.home_batting_spot_9_walks_per_game_career
    
    feature_set << feature.away_batting_spot_1_walks_per_game_career
    feature_set << feature.away_batting_spot_2_walks_per_game_career
    feature_set << feature.away_batting_spot_3_walks_per_game_career
    feature_set << feature.away_batting_spot_4_walks_per_game_career
    feature_set << feature.away_batting_spot_5_walks_per_game_career
    feature_set << feature.away_batting_spot_6_walks_per_game_career
    feature_set << feature.away_batting_spot_7_walks_per_game_career
    feature_set << feature.away_batting_spot_8_walks_per_game_career
    feature_set << feature.away_batting_spot_9_walks_per_game_career
    
    feature_set << feature.home_batting_spot_1_batting_percentage_career
    feature_set << feature.home_batting_spot_2_batting_percentage_career
    feature_set << feature.home_batting_spot_3_batting_percentage_career
    feature_set << feature.home_batting_spot_4_batting_percentage_career
    feature_set << feature.home_batting_spot_5_batting_percentage_career
    feature_set << feature.home_batting_spot_6_batting_percentage_career
    feature_set << feature.home_batting_spot_7_batting_percentage_career
    feature_set << feature.home_batting_spot_8_batting_percentage_career
    feature_set << feature.home_batting_spot_9_batting_percentage_career
    
    feature_set << feature.away_batting_spot_1_batting_percentage_career
    feature_set << feature.away_batting_spot_2_batting_percentage_career
    feature_set << feature.away_batting_spot_3_batting_percentage_career
    feature_set << feature.away_batting_spot_4_batting_percentage_career
    feature_set << feature.away_batting_spot_5_batting_percentage_career
    feature_set << feature.away_batting_spot_6_batting_percentage_career
    feature_set << feature.away_batting_spot_7_batting_percentage_career
    feature_set << feature.away_batting_spot_8_batting_percentage_career
    feature_set << feature.away_batting_spot_9_batting_percentage_career
    
    feature_set << feature.home_batting_spot_1_OPS_career
    feature_set << feature.home_batting_spot_2_OPS_career
    feature_set << feature.home_batting_spot_3_OPS_career
    feature_set << feature.home_batting_spot_4_OPS_career
    feature_set << feature.home_batting_spot_5_OPS_career
    feature_set << feature.home_batting_spot_6_OPS_career
    feature_set << feature.home_batting_spot_7_OPS_career
    feature_set << feature.home_batting_spot_8_OPS_career
    feature_set << feature.home_batting_spot_9_OPS_career
    
    feature_set << feature.away_batting_spot_1_OPS_career
    feature_set << feature.away_batting_spot_2_OPS_career
    feature_set << feature.away_batting_spot_3_OPS_career
    feature_set << feature.away_batting_spot_4_OPS_career
    feature_set << feature.away_batting_spot_5_OPS_career
    feature_set << feature.away_batting_spot_6_OPS_career
    feature_set << feature.away_batting_spot_7_OPS_career
    feature_set << feature.away_batting_spot_8_OPS_career
    feature_set << feature.away_batting_spot_9_OPS_career
    
    feature_set << feature.home_batting_spot_1_strikeout_rate_career
    feature_set << feature.home_batting_spot_2_strikeout_rate_career
    feature_set << feature.home_batting_spot_3_strikeout_rate_career
    feature_set << feature.home_batting_spot_4_strikeout_rate_career
    feature_set << feature.home_batting_spot_5_strikeout_rate_career
    feature_set << feature.home_batting_spot_6_strikeout_rate_career
    feature_set << feature.home_batting_spot_7_strikeout_rate_career
    feature_set << feature.home_batting_spot_8_strikeout_rate_career
    feature_set << feature.home_batting_spot_9_strikeout_rate_career
    
    feature_set << feature.away_batting_spot_1_strikeout_rate_career
    feature_set << feature.away_batting_spot_2_strikeout_rate_career
    feature_set << feature.away_batting_spot_3_strikeout_rate_career
    feature_set << feature.away_batting_spot_4_strikeout_rate_career
    feature_set << feature.away_batting_spot_5_strikeout_rate_career
    feature_set << feature.away_batting_spot_6_strikeout_rate_career
    feature_set << feature.away_batting_spot_7_strikeout_rate_career
    feature_set << feature.away_batting_spot_8_strikeout_rate_career
    feature_set << feature.away_batting_spot_9_strikeout_rate_career    
#=end

=begin
    feature_set << feature.home_batting_spot_1_walks_last_1_game - feature.away_batting_spot_1_walks_last_1_game
    feature_set << feature.home_batting_spot_2_walks_last_1_game - feature.away_batting_spot_2_walks_last_1_game
    feature_set << feature.home_batting_spot_3_walks_last_1_game - feature.away_batting_spot_3_walks_last_1_game
    feature_set << feature.home_batting_spot_4_walks_last_1_game - feature.away_batting_spot_4_walks_last_1_game
    feature_set << feature.home_batting_spot_5_walks_last_1_game - feature.away_batting_spot_5_walks_last_1_game
    feature_set << feature.home_batting_spot_6_walks_last_1_game - feature.away_batting_spot_6_walks_last_1_game
    feature_set << feature.home_batting_spot_7_walks_last_1_game - feature.away_batting_spot_7_walks_last_1_game
    feature_set << feature.home_batting_spot_8_walks_last_1_game - feature.away_batting_spot_8_walks_last_1_game
    feature_set << feature.home_batting_spot_9_walks_last_1_game - feature.away_batting_spot_9_walks_last_1_game
=end

=begin
    walk_diff = 0
    walk_diff += feature.home_batting_spot_1_walks_last_1_game - feature.away_batting_spot_1_walks_last_1_game
    walk_diff += feature.home_batting_spot_2_walks_last_1_game - feature.away_batting_spot_2_walks_last_1_game
    walk_diff += feature.home_batting_spot_3_walks_last_1_game - feature.away_batting_spot_3_walks_last_1_game
    walk_diff += feature.home_batting_spot_4_walks_last_1_game - feature.away_batting_spot_4_walks_last_1_game
    walk_diff += feature.home_batting_spot_5_walks_last_1_game - feature.away_batting_spot_5_walks_last_1_game
    walk_diff += feature.home_batting_spot_6_walks_last_1_game - feature.away_batting_spot_6_walks_last_1_game
    walk_diff += feature.home_batting_spot_7_walks_last_1_game - feature.away_batting_spot_7_walks_last_1_game
    walk_diff += feature.home_batting_spot_8_walks_last_1_game - feature.away_batting_spot_8_walks_last_1_game
    walk_diff += feature.home_batting_spot_9_walks_last_1_game - feature.away_batting_spot_9_walks_last_1_game
    feature_set << walk_diff
=end
    

    #feature_set << (feature.home_team_won ? 1 : -1)

    examples << feature_set
    labels << (feature.home_team_won ? 1 : 0)
  end
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []
addFeaturesAndLabel(DateTime.parse("20080101"), DateTime.parse("20100101"), training_examples, training_labels)

puts "generating testing set...."
testing_examples = []
testing_labels = []
addFeaturesAndLabel(DateTime.parse("20100101"), DateTime.parse("20110101"), testing_examples, testing_labels)

#=begin
File.open("train_matrix.out", 'w') do |f|
  training_examples.each_with_index do |example, i|
    f.write(training_labels[i])
    example.each do |feature|
      f.write(',')
      f.write(feature)
    end
    f.write("\n")
  end
end

File.open("test_matrix.out", 'w') do |f|
  testing_examples.each_with_index do |example, i|
    f.write(testing_labels[i])
    example.each do |feature|
      f.write(',')
      f.write(feature)
    end
    f.write("\n")
  end
end
#=end
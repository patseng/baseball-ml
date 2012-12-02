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

def addBlankPlayer(retrosheet_id, hash)
  perfs = Hash.new

  perfs["career_games"] = 0
  
  perfs["at_bats_last_1_game"] = [0]
  perfs["at_bats_last_2_games"] = [0, 0]
  perfs["at_bats_last_5_games"] = [0, 0, 0, 0, 0]
  perfs["at_bats_last_10_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  perfs["at_bats_last_20_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  perfs["career_at_bats"] = 0
  
  perfs["walks_last_1_game"] = [0]
  perfs["walks_last_2_games"] = [0, 0]
  perfs["walks_last_5_games"] = [0, 0, 0, 0, 0]
  perfs["walks_last_10_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  perfs["walks_last_20_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  perfs["career_walks"] = 0
    
  perfs["hits_last_1_game"] = [0]
  perfs["hits_last_2_games"] = [0, 0]
  perfs["hits_last_5_games"] = [0, 0, 0, 0, 0]
  perfs["hits_last_10_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  perfs["hits_last_20_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  perfs["career_hits"] = 0
  
  perfs["strikeouts_last_1_game"] = [0]
  perfs["strikeouts_last_2_games"] = [0, 0]
  perfs["strikeouts_last_5_games"] = [0, 0, 0, 0, 0]
  perfs["strikeouts_last_10_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  perfs["strikeouts_last_20_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  perfs["career_strikeouts"] = 0
  
  perfs["total_bases_last_1_game"] = [0]
  perfs["total_bases_last_2_games"] = [0, 0]
  perfs["total_bases_last_5_games"] = [0, 0, 0, 0, 0]
  perfs["total_bases_last_10_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  perfs["total_bases_last_20_games"] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  perfs["career_total_bases"] = 0
  
  hash[retrosheet_id] = perfs
end

# Adding last 1, 2, 5, 10, and 20 games
def addFeaturesAndLabel(team, earliest_date, latest_date, examples, labels)
  home_faceoffs = Game.where("home_team = ? and game_date > ? and game_date <= ?", team, earliest_date, latest_date).order("game_date desc")
  away_faceoffs = Game.where("away_team = ? and game_date > ? and game_date <= ?", team, earliest_date, latest_date).order("game_date desc")
  past_games = home_faceoffs.concat(away_faceoffs)

  # games sort in ascending order.  The first game of the 2001 season is located first
  past_games = past_games.sort {|game1, game2| game1.game_date <=> game2.game_date }
  
  player_performances = Hash.new

  past_games.each_with_index do |past_game, index|
    feature_set = Feature.find_by_game_id(past_game.id)
    performances = Performance.where("game_id = ?", past_game.id)

    performances.each do |perf|
      player = Player.find_by_id(perf.player_id)
      if !player_performances.has_key?(player.retrosheet_id)
        addBlankPlayer(player.retrosheet_id, player_performances)
      end
    end

    if past_game.home_team == team.to_s
      feature_set.home_batting_spot_1_walks_last_1_game = player_performances[past_game.home_batting_spot_1]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_2_walks_last_1_game = player_performances[past_game.home_batting_spot_2]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_3_walks_last_1_game = player_performances[past_game.home_batting_spot_3]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_4_walks_last_1_game = player_performances[past_game.home_batting_spot_4]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_5_walks_last_1_game = player_performances[past_game.home_batting_spot_5]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_6_walks_last_1_game = player_performances[past_game.home_batting_spot_6]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_7_walks_last_1_game = player_performances[past_game.home_batting_spot_7]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_8_walks_last_1_game = player_performances[past_game.home_batting_spot_8]["walks_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_9_walks_last_1_game = player_performances[past_game.home_batting_spot_9]["walks_last_1_game"].reduce(:+)

      feature_set.home_batting_spot_1_walks_last_2_games = player_performances[past_game.home_batting_spot_1]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_2_walks_last_2_games = player_performances[past_game.home_batting_spot_2]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_3_walks_last_2_games = player_performances[past_game.home_batting_spot_3]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_4_walks_last_2_games = player_performances[past_game.home_batting_spot_4]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_5_walks_last_2_games = player_performances[past_game.home_batting_spot_5]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_6_walks_last_2_games = player_performances[past_game.home_batting_spot_6]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_7_walks_last_2_games = player_performances[past_game.home_batting_spot_7]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_8_walks_last_2_games = player_performances[past_game.home_batting_spot_8]["walks_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_9_walks_last_2_games = player_performances[past_game.home_batting_spot_9]["walks_last_2_games"].reduce(:+)

      feature_set.home_batting_spot_1_walks_last_5_games = player_performances[past_game.home_batting_spot_1]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_2_walks_last_5_games = player_performances[past_game.home_batting_spot_2]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_3_walks_last_5_games = player_performances[past_game.home_batting_spot_3]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_4_walks_last_5_games = player_performances[past_game.home_batting_spot_4]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_5_walks_last_5_games = player_performances[past_game.home_batting_spot_5]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_6_walks_last_5_games = player_performances[past_game.home_batting_spot_6]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_7_walks_last_5_games = player_performances[past_game.home_batting_spot_7]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_8_walks_last_5_games = player_performances[past_game.home_batting_spot_8]["walks_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_9_walks_last_5_games = player_performances[past_game.home_batting_spot_9]["walks_last_5_games"].reduce(:+)

      feature_set.home_batting_spot_1_walks_last_10_games = player_performances[past_game.home_batting_spot_1]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_2_walks_last_10_games = player_performances[past_game.home_batting_spot_2]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_3_walks_last_10_games = player_performances[past_game.home_batting_spot_3]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_4_walks_last_10_games = player_performances[past_game.home_batting_spot_4]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_5_walks_last_10_games = player_performances[past_game.home_batting_spot_5]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_6_walks_last_10_games = player_performances[past_game.home_batting_spot_6]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_7_walks_last_10_games = player_performances[past_game.home_batting_spot_7]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_8_walks_last_10_games = player_performances[past_game.home_batting_spot_8]["walks_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_9_walks_last_10_games = player_performances[past_game.home_batting_spot_9]["walks_last_10_games"].reduce(:+)

      feature_set.home_batting_spot_1_walks_last_20_games = player_performances[past_game.home_batting_spot_1]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_2_walks_last_20_games = player_performances[past_game.home_batting_spot_2]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_3_walks_last_20_games = player_performances[past_game.home_batting_spot_3]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_4_walks_last_20_games = player_performances[past_game.home_batting_spot_4]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_5_walks_last_20_games = player_performances[past_game.home_batting_spot_5]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_6_walks_last_20_games = player_performances[past_game.home_batting_spot_6]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_7_walks_last_20_games = player_performances[past_game.home_batting_spot_7]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_8_walks_last_20_games = player_performances[past_game.home_batting_spot_8]["walks_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_9_walks_last_20_games = player_performances[past_game.home_batting_spot_9]["walks_last_20_games"].reduce(:+)

            
      feature_set.home_batting_spot_1_walks_per_game_career = player_performances[past_game.home_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["career_walks"] / player_performances[past_game.home_batting_spot_1]["career_games"]
      feature_set.home_batting_spot_2_walks_per_game_career = player_performances[past_game.home_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["career_walks"] / player_performances[past_game.home_batting_spot_2]["career_games"]
      feature_set.home_batting_spot_3_walks_per_game_career = player_performances[past_game.home_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["career_walks"] / player_performances[past_game.home_batting_spot_3]["career_games"]
      feature_set.home_batting_spot_4_walks_per_game_career = player_performances[past_game.home_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["career_walks"] / player_performances[past_game.home_batting_spot_4]["career_games"]
      feature_set.home_batting_spot_5_walks_per_game_career = player_performances[past_game.home_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["career_walks"] / player_performances[past_game.home_batting_spot_5]["career_games"]
      feature_set.home_batting_spot_6_walks_per_game_career = player_performances[past_game.home_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["career_walks"] / player_performances[past_game.home_batting_spot_6]["career_games"]
      feature_set.home_batting_spot_7_walks_per_game_career = player_performances[past_game.home_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["career_walks"] / player_performances[past_game.home_batting_spot_7]["career_games"]
      feature_set.home_batting_spot_8_walks_per_game_career = player_performances[past_game.home_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["career_walks"] / player_performances[past_game.home_batting_spot_8]["career_games"]
      feature_set.home_batting_spot_9_walks_per_game_career = player_performances[past_game.home_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["career_walks"] / player_performances[past_game.home_batting_spot_9]["career_games"]
            

      feature_set.home_batting_spot_1_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_1]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_2_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_2]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_3_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_3]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_4_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_4]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_5_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_5]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_6_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_6]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_7_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_7]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_8_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_8]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_9_batting_percentage_last_1_game = player_performances[past_game.home_batting_spot_9]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_1_game"].reduce(:+)

      feature_set.home_batting_spot_1_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_2_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_3_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_4_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_5_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_6_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_7_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_8_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_9_batting_percentage_last_2_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_2_games"].reduce(:+)

      feature_set.home_batting_spot_1_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_2_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_3_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_4_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_5_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_6_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_7_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_8_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_9_batting_percentage_last_5_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_5_games"].reduce(:+)

      feature_set.home_batting_spot_1_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_2_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_3_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_4_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_5_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_6_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_7_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_8_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_9_batting_percentage_last_10_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_10_games"].reduce(:+)

      feature_set.home_batting_spot_1_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_2_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_3_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_4_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_5_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_6_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_7_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_8_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_9_batting_percentage_last_20_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_20_games"].reduce(:+)

      feature_set.home_batting_spot_1_batting_percentage_career = player_performances[past_game.home_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["career_hits"] / player_performances[past_game.home_batting_spot_1]["career_games"]
      feature_set.home_batting_spot_2_batting_percentage_career = player_performances[past_game.home_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["career_hits"] / player_performances[past_game.home_batting_spot_2]["career_games"]
      feature_set.home_batting_spot_3_batting_percentage_career = player_performances[past_game.home_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["career_hits"] / player_performances[past_game.home_batting_spot_3]["career_games"]
      feature_set.home_batting_spot_4_batting_percentage_career = player_performances[past_game.home_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["career_hits"] / player_performances[past_game.home_batting_spot_4]["career_games"]
      feature_set.home_batting_spot_5_batting_percentage_career = player_performances[past_game.home_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["career_hits"] / player_performances[past_game.home_batting_spot_5]["career_games"]
      feature_set.home_batting_spot_6_batting_percentage_career = player_performances[past_game.home_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["career_hits"] / player_performances[past_game.home_batting_spot_6]["career_games"]
      feature_set.home_batting_spot_7_batting_percentage_career = player_performances[past_game.home_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["career_hits"] / player_performances[past_game.home_batting_spot_7]["career_games"]
      feature_set.home_batting_spot_8_batting_percentage_career = player_performances[past_game.home_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["career_hits"] / player_performances[past_game.home_batting_spot_8]["career_games"]
      feature_set.home_batting_spot_9_batting_percentage_career = player_performances[past_game.home_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["career_hits"] / player_performances[past_game.home_batting_spot_9]["career_games"]

      feature_set.home_batting_spot_1_OPS_last_1_game = player_performances[past_game.home_batting_spot_1]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_2_OPS_last_1_game = player_performances[past_game.home_batting_spot_2]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_3_OPS_last_1_game = player_performances[past_game.home_batting_spot_3]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_4_OPS_last_1_game = player_performances[past_game.home_batting_spot_4]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_5_OPS_last_1_game = player_performances[past_game.home_batting_spot_5]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_6_OPS_last_1_game = player_performances[past_game.home_batting_spot_6]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_7_OPS_last_1_game = player_performances[past_game.home_batting_spot_7]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_8_OPS_last_1_game = player_performances[past_game.home_batting_spot_8]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_9_OPS_last_1_game = player_performances[past_game.home_batting_spot_9]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_1_game"].reduce(:+)

      feature_set.home_batting_spot_1_OPS_last_2_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_2_OPS_last_2_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_3_OPS_last_2_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_4_OPS_last_2_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_5_OPS_last_2_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_6_OPS_last_2_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_7_OPS_last_2_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_8_OPS_last_2_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_9_OPS_last_2_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_2_games"].reduce(:+)

      feature_set.home_batting_spot_1_OPS_last_5_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_2_OPS_last_5_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_3_OPS_last_5_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_4_OPS_last_5_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_5_OPS_last_5_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_6_OPS_last_5_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_7_OPS_last_5_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_8_OPS_last_5_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_9_OPS_last_5_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_5_games"].reduce(:+)

      feature_set.home_batting_spot_1_OPS_last_10_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_2_OPS_last_10_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_3_OPS_last_10_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_4_OPS_last_10_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_5_OPS_last_10_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_6_OPS_last_10_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_7_OPS_last_10_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_8_OPS_last_10_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_9_OPS_last_10_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_10_games"].reduce(:+)

      feature_set.home_batting_spot_1_OPS_last_20_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_2_OPS_last_20_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_3_OPS_last_20_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_4_OPS_last_20_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_5_OPS_last_20_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_6_OPS_last_20_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_7_OPS_last_20_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_8_OPS_last_20_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_9_OPS_last_20_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_20_games"].reduce(:+)

      feature_set.home_batting_spot_1_OPS_career = player_performances[past_game.home_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["career_total_bases"] / player_performances[past_game.home_batting_spot_1]["career_games"]
      feature_set.home_batting_spot_2_OPS_career = player_performances[past_game.home_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["career_total_bases"] / player_performances[past_game.home_batting_spot_2]["career_games"]
      feature_set.home_batting_spot_3_OPS_career = player_performances[past_game.home_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["career_total_bases"] / player_performances[past_game.home_batting_spot_3]["career_games"]
      feature_set.home_batting_spot_4_OPS_career = player_performances[past_game.home_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["career_total_bases"] / player_performances[past_game.home_batting_spot_4]["career_games"]
      feature_set.home_batting_spot_5_OPS_career = player_performances[past_game.home_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["career_total_bases"] / player_performances[past_game.home_batting_spot_5]["career_games"]
      feature_set.home_batting_spot_6_OPS_career = player_performances[past_game.home_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["career_total_bases"] / player_performances[past_game.home_batting_spot_6]["career_games"]
      feature_set.home_batting_spot_7_OPS_career = player_performances[past_game.home_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["career_total_bases"] / player_performances[past_game.home_batting_spot_7]["career_games"]
      feature_set.home_batting_spot_8_OPS_career = player_performances[past_game.home_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["career_total_bases"] / player_performances[past_game.home_batting_spot_8]["career_games"]
      feature_set.home_batting_spot_9_OPS_career = player_performances[past_game.home_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["career_total_bases"] / player_performances[past_game.home_batting_spot_9]["career_games"]

      feature_set.home_batting_spot_1_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_1]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_2_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_2]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_3_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_3]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_4_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_4]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_5_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_5]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_6_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_6]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_7_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_7]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_8_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_8]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_1_game"].reduce(:+)
      feature_set.home_batting_spot_9_strikeout_rate_last_1_game = player_performances[past_game.home_batting_spot_9]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_1_game"].reduce(:+)

      feature_set.home_batting_spot_1_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_2_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_3_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_4_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_5_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_6_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_7_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_8_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_2_games"].reduce(:+)
      feature_set.home_batting_spot_9_strikeout_rate_last_2_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_2_games"].reduce(:+)

      feature_set.home_batting_spot_1_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_2_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_3_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_4_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_5_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_6_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_7_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_8_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_5_games"].reduce(:+)
      feature_set.home_batting_spot_9_strikeout_rate_last_5_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_5_games"].reduce(:+)

      feature_set.home_batting_spot_1_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_2_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_3_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_4_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_5_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_6_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_7_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_8_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_10_games"].reduce(:+)
      feature_set.home_batting_spot_9_strikeout_rate_last_10_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_10_games"].reduce(:+)

      feature_set.home_batting_spot_1_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_1]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_1]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_2_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_2]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_2]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_3_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_3]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_3]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_4_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_4]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_4]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_5_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_5]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_5]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_6_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_6]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_6]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_7_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_7]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_7]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_8_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_8]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_8]["at_bats_last_20_games"].reduce(:+)
      feature_set.home_batting_spot_9_strikeout_rate_last_20_games = player_performances[past_game.home_batting_spot_9]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.home_batting_spot_9]["at_bats_last_20_games"].reduce(:+)
      
      feature_set.home_batting_spot_1_strikeout_rate_career = player_performances[past_game.home_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_1]["career_strikeouts"] / player_performances[past_game.home_batting_spot_1]["career_games"]
      feature_set.home_batting_spot_2_strikeout_rate_career = player_performances[past_game.home_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_2]["career_strikeouts"] / player_performances[past_game.home_batting_spot_2]["career_games"]
      feature_set.home_batting_spot_3_strikeout_rate_career = player_performances[past_game.home_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_3]["career_strikeouts"] / player_performances[past_game.home_batting_spot_3]["career_games"]
      feature_set.home_batting_spot_4_strikeout_rate_career = player_performances[past_game.home_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_4]["career_strikeouts"] / player_performances[past_game.home_batting_spot_4]["career_games"]
      feature_set.home_batting_spot_5_strikeout_rate_career = player_performances[past_game.home_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_5]["career_strikeouts"] / player_performances[past_game.home_batting_spot_5]["career_games"]
      feature_set.home_batting_spot_6_strikeout_rate_career = player_performances[past_game.home_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_6]["career_strikeouts"] / player_performances[past_game.home_batting_spot_6]["career_games"]
      feature_set.home_batting_spot_7_strikeout_rate_career = player_performances[past_game.home_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_7]["career_strikeouts"] / player_performances[past_game.home_batting_spot_7]["career_games"]
      feature_set.home_batting_spot_8_strikeout_rate_career = player_performances[past_game.home_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_8]["career_strikeouts"] / player_performances[past_game.home_batting_spot_8]["career_games"]
      feature_set.home_batting_spot_9_strikeout_rate_career = player_performances[past_game.home_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.home_batting_spot_9]["career_strikeouts"] / player_performances[past_game.home_batting_spot_9]["career_games"]
    else
      
      feature_set.away_batting_spot_1_walks_last_1_game = player_performances[past_game.away_batting_spot_1]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_2_walks_last_1_game = player_performances[past_game.away_batting_spot_2]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_3_walks_last_1_game = player_performances[past_game.away_batting_spot_3]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_4_walks_last_1_game = player_performances[past_game.away_batting_spot_4]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_5_walks_last_1_game = player_performances[past_game.away_batting_spot_5]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_6_walks_last_1_game = player_performances[past_game.away_batting_spot_6]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_7_walks_last_1_game = player_performances[past_game.away_batting_spot_7]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_8_walks_last_1_game = player_performances[past_game.away_batting_spot_8]["walks_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_9_walks_last_1_game = player_performances[past_game.away_batting_spot_9]["walks_last_1_game"].reduce(:+)

      feature_set.away_batting_spot_1_walks_last_2_games = player_performances[past_game.away_batting_spot_1]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_2_walks_last_2_games = player_performances[past_game.away_batting_spot_2]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_3_walks_last_2_games = player_performances[past_game.away_batting_spot_3]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_4_walks_last_2_games = player_performances[past_game.away_batting_spot_4]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_5_walks_last_2_games = player_performances[past_game.away_batting_spot_5]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_6_walks_last_2_games = player_performances[past_game.away_batting_spot_6]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_7_walks_last_2_games = player_performances[past_game.away_batting_spot_7]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_8_walks_last_2_games = player_performances[past_game.away_batting_spot_8]["walks_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_9_walks_last_2_games = player_performances[past_game.away_batting_spot_9]["walks_last_2_games"].reduce(:+)

      feature_set.away_batting_spot_1_walks_last_5_games = player_performances[past_game.away_batting_spot_1]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_2_walks_last_5_games = player_performances[past_game.away_batting_spot_2]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_3_walks_last_5_games = player_performances[past_game.away_batting_spot_3]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_4_walks_last_5_games = player_performances[past_game.away_batting_spot_4]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_5_walks_last_5_games = player_performances[past_game.away_batting_spot_5]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_6_walks_last_5_games = player_performances[past_game.away_batting_spot_6]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_7_walks_last_5_games = player_performances[past_game.away_batting_spot_7]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_8_walks_last_5_games = player_performances[past_game.away_batting_spot_8]["walks_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_9_walks_last_5_games = player_performances[past_game.away_batting_spot_9]["walks_last_5_games"].reduce(:+)

      feature_set.away_batting_spot_1_walks_last_10_games = player_performances[past_game.away_batting_spot_1]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_2_walks_last_10_games = player_performances[past_game.away_batting_spot_2]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_3_walks_last_10_games = player_performances[past_game.away_batting_spot_3]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_4_walks_last_10_games = player_performances[past_game.away_batting_spot_4]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_5_walks_last_10_games = player_performances[past_game.away_batting_spot_5]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_6_walks_last_10_games = player_performances[past_game.away_batting_spot_6]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_7_walks_last_10_games = player_performances[past_game.away_batting_spot_7]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_8_walks_last_10_games = player_performances[past_game.away_batting_spot_8]["walks_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_9_walks_last_10_games = player_performances[past_game.away_batting_spot_9]["walks_last_10_games"].reduce(:+)

      feature_set.away_batting_spot_1_walks_last_20_games = player_performances[past_game.away_batting_spot_1]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_2_walks_last_20_games = player_performances[past_game.away_batting_spot_2]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_3_walks_last_20_games = player_performances[past_game.away_batting_spot_3]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_4_walks_last_20_games = player_performances[past_game.away_batting_spot_4]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_5_walks_last_20_games = player_performances[past_game.away_batting_spot_5]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_6_walks_last_20_games = player_performances[past_game.away_batting_spot_6]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_7_walks_last_20_games = player_performances[past_game.away_batting_spot_7]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_8_walks_last_20_games = player_performances[past_game.away_batting_spot_8]["walks_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_9_walks_last_20_games = player_performances[past_game.away_batting_spot_9]["walks_last_20_games"].reduce(:+)

      feature_set.away_batting_spot_1_walks_per_game_career = player_performances[past_game.away_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["career_walks"] / player_performances[past_game.away_batting_spot_1]["career_games"]
      feature_set.away_batting_spot_2_walks_per_game_career = player_performances[past_game.away_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["career_walks"] / player_performances[past_game.away_batting_spot_2]["career_games"]
      feature_set.away_batting_spot_3_walks_per_game_career = player_performances[past_game.away_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["career_walks"] / player_performances[past_game.away_batting_spot_3]["career_games"]
      feature_set.away_batting_spot_4_walks_per_game_career = player_performances[past_game.away_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["career_walks"] / player_performances[past_game.away_batting_spot_4]["career_games"]
      feature_set.away_batting_spot_5_walks_per_game_career = player_performances[past_game.away_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["career_walks"] / player_performances[past_game.away_batting_spot_5]["career_games"]
      feature_set.away_batting_spot_6_walks_per_game_career = player_performances[past_game.away_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["career_walks"] / player_performances[past_game.away_batting_spot_6]["career_games"]
      feature_set.away_batting_spot_7_walks_per_game_career = player_performances[past_game.away_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["career_walks"] / player_performances[past_game.away_batting_spot_7]["career_games"]
      feature_set.away_batting_spot_8_walks_per_game_career = player_performances[past_game.away_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["career_walks"] / player_performances[past_game.away_batting_spot_8]["career_games"]
      feature_set.away_batting_spot_9_walks_per_game_career = player_performances[past_game.away_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["career_walks"] / player_performances[past_game.away_batting_spot_9]["career_games"]
      

      feature_set.away_batting_spot_1_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_1]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_2_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_2]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_3_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_3]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_4_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_4]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_5_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_5]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_6_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_6]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_7_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_7]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_8_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_8]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_9_batting_percentage_last_1_game = player_performances[past_game.away_batting_spot_9]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["hits_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_1_game"].reduce(:+)

      feature_set.away_batting_spot_1_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_2_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_3_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_4_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_5_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_6_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_7_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_8_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_9_batting_percentage_last_2_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["hits_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_2_games"].reduce(:+)

      feature_set.away_batting_spot_1_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_2_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_3_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_4_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_5_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_6_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_7_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_8_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_9_batting_percentage_last_5_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["hits_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_5_games"].reduce(:+)

      feature_set.away_batting_spot_1_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_2_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_3_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_4_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_5_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_6_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_7_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_8_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_9_batting_percentage_last_10_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["hits_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_10_games"].reduce(:+)

      feature_set.away_batting_spot_1_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_2_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_3_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_4_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_5_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_6_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_7_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_8_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_9_batting_percentage_last_20_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["hits_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_20_games"].reduce(:+)
      
      feature_set.away_batting_spot_1_batting_percentage_career = player_performances[past_game.away_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["career_hits"] / player_performances[past_game.away_batting_spot_1]["career_games"]
      feature_set.away_batting_spot_2_batting_percentage_career = player_performances[past_game.away_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["career_hits"] / player_performances[past_game.away_batting_spot_2]["career_games"]
      feature_set.away_batting_spot_3_batting_percentage_career = player_performances[past_game.away_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["career_hits"] / player_performances[past_game.away_batting_spot_3]["career_games"]
      feature_set.away_batting_spot_4_batting_percentage_career = player_performances[past_game.away_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["career_hits"] / player_performances[past_game.away_batting_spot_4]["career_games"]
      feature_set.away_batting_spot_5_batting_percentage_career = player_performances[past_game.away_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["career_hits"] / player_performances[past_game.away_batting_spot_5]["career_games"]
      feature_set.away_batting_spot_6_batting_percentage_career = player_performances[past_game.away_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["career_hits"] / player_performances[past_game.away_batting_spot_6]["career_games"]
      feature_set.away_batting_spot_7_batting_percentage_career = player_performances[past_game.away_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["career_hits"] / player_performances[past_game.away_batting_spot_7]["career_games"]
      feature_set.away_batting_spot_8_batting_percentage_career = player_performances[past_game.away_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["career_hits"] / player_performances[past_game.away_batting_spot_8]["career_games"]
      feature_set.away_batting_spot_9_batting_percentage_career = player_performances[past_game.away_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["career_hits"] / player_performances[past_game.away_batting_spot_9]["career_games"]

      feature_set.away_batting_spot_1_OPS_last_1_game = player_performances[past_game.away_batting_spot_1]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_2_OPS_last_1_game = player_performances[past_game.away_batting_spot_2]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_3_OPS_last_1_game = player_performances[past_game.away_batting_spot_3]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_4_OPS_last_1_game = player_performances[past_game.away_batting_spot_4]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_5_OPS_last_1_game = player_performances[past_game.away_batting_spot_5]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_6_OPS_last_1_game = player_performances[past_game.away_batting_spot_6]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_7_OPS_last_1_game = player_performances[past_game.away_batting_spot_7]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_8_OPS_last_1_game = player_performances[past_game.away_batting_spot_8]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_9_OPS_last_1_game = player_performances[past_game.away_batting_spot_9]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["total_bases_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_1_game"].reduce(:+)

      feature_set.away_batting_spot_1_OPS_last_2_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_2_OPS_last_2_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_3_OPS_last_2_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_4_OPS_last_2_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_5_OPS_last_2_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_6_OPS_last_2_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_7_OPS_last_2_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_8_OPS_last_2_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_9_OPS_last_2_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["total_bases_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_2_games"].reduce(:+)

      feature_set.away_batting_spot_1_OPS_last_5_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_2_OPS_last_5_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_3_OPS_last_5_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_4_OPS_last_5_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_5_OPS_last_5_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_6_OPS_last_5_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_7_OPS_last_5_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_8_OPS_last_5_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_9_OPS_last_5_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["total_bases_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_5_games"].reduce(:+)

      feature_set.away_batting_spot_1_OPS_last_10_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_2_OPS_last_10_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_3_OPS_last_10_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_4_OPS_last_10_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_5_OPS_last_10_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_6_OPS_last_10_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_7_OPS_last_10_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_8_OPS_last_10_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_9_OPS_last_10_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["total_bases_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_10_games"].reduce(:+)

      feature_set.away_batting_spot_1_OPS_last_20_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_2_OPS_last_20_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_3_OPS_last_20_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_4_OPS_last_20_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_5_OPS_last_20_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_6_OPS_last_20_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_7_OPS_last_20_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_8_OPS_last_20_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_9_OPS_last_20_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["total_bases_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_20_games"].reduce(:+)
      
      feature_set.away_batting_spot_1_OPS_career = player_performances[past_game.away_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["career_total_bases"] / player_performances[past_game.away_batting_spot_1]["career_games"]
      feature_set.away_batting_spot_2_OPS_career = player_performances[past_game.away_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["career_total_bases"] / player_performances[past_game.away_batting_spot_2]["career_games"]
      feature_set.away_batting_spot_3_OPS_career = player_performances[past_game.away_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["career_total_bases"] / player_performances[past_game.away_batting_spot_3]["career_games"]
      feature_set.away_batting_spot_4_OPS_career = player_performances[past_game.away_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["career_total_bases"] / player_performances[past_game.away_batting_spot_4]["career_games"]
      feature_set.away_batting_spot_5_OPS_career = player_performances[past_game.away_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["career_total_bases"] / player_performances[past_game.away_batting_spot_5]["career_games"]
      feature_set.away_batting_spot_6_OPS_career = player_performances[past_game.away_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["career_total_bases"] / player_performances[past_game.away_batting_spot_6]["career_games"]
      feature_set.away_batting_spot_7_OPS_career = player_performances[past_game.away_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["career_total_bases"] / player_performances[past_game.away_batting_spot_7]["career_games"]
      feature_set.away_batting_spot_8_OPS_career = player_performances[past_game.away_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["career_total_bases"] / player_performances[past_game.away_batting_spot_8]["career_games"]
      feature_set.away_batting_spot_9_OPS_career = player_performances[past_game.away_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["career_total_bases"] / player_performances[past_game.away_batting_spot_9]["career_games"]

      feature_set.away_batting_spot_1_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_1]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_2_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_2]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_3_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_3]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_4_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_4]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_5_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_5]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_6_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_6]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_7_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_7]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_8_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_8]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_1_game"].reduce(:+)
      feature_set.away_batting_spot_9_strikeout_rate_last_1_game = player_performances[past_game.away_batting_spot_9]["at_bats_last_1_game"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["strikeouts_last_1_game"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_1_game"].reduce(:+)

      feature_set.away_batting_spot_1_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_2_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_3_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_4_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_5_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_6_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_7_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_8_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_2_games"].reduce(:+)
      feature_set.away_batting_spot_9_strikeout_rate_last_2_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_2_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["strikeouts_last_2_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_2_games"].reduce(:+)

      feature_set.away_batting_spot_1_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_2_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_3_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_4_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_5_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_6_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_7_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_8_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_5_games"].reduce(:+)
      feature_set.away_batting_spot_9_strikeout_rate_last_5_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_5_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["strikeouts_last_5_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_5_games"].reduce(:+)

      feature_set.away_batting_spot_1_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_2_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_3_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_4_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_5_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_6_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_7_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_8_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_10_games"].reduce(:+)
      feature_set.away_batting_spot_9_strikeout_rate_last_10_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_10_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["strikeouts_last_10_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_10_games"].reduce(:+)

      feature_set.away_batting_spot_1_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_1]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_1]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_2_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_2]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_2]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_3_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_3]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_3]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_4_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_4]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_4]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_5_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_5]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_5]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_6_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_6]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_6]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_7_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_7]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_7]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_8_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_8]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_8]["at_bats_last_20_games"].reduce(:+)
      feature_set.away_batting_spot_9_strikeout_rate_last_20_games = player_performances[past_game.away_batting_spot_9]["at_bats_last_20_games"].reduce(:+) == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["strikeouts_last_20_games"].reduce(:+).to_f / player_performances[past_game.away_batting_spot_9]["at_bats_last_20_games"].reduce(:+)
      
      feature_set.away_batting_spot_1_strikeout_rate_career = player_performances[past_game.away_batting_spot_1]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_1]["career_strikeouts"] / player_performances[past_game.away_batting_spot_1]["career_games"]
      feature_set.away_batting_spot_2_strikeout_rate_career = player_performances[past_game.away_batting_spot_2]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_2]["career_strikeouts"] / player_performances[past_game.away_batting_spot_2]["career_games"]
      feature_set.away_batting_spot_3_strikeout_rate_career = player_performances[past_game.away_batting_spot_3]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_3]["career_strikeouts"] / player_performances[past_game.away_batting_spot_3]["career_games"]
      feature_set.away_batting_spot_4_strikeout_rate_career = player_performances[past_game.away_batting_spot_4]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_4]["career_strikeouts"] / player_performances[past_game.away_batting_spot_4]["career_games"]
      feature_set.away_batting_spot_5_strikeout_rate_career = player_performances[past_game.away_batting_spot_5]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_5]["career_strikeouts"] / player_performances[past_game.away_batting_spot_5]["career_games"]
      feature_set.away_batting_spot_6_strikeout_rate_career = player_performances[past_game.away_batting_spot_6]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_6]["career_strikeouts"] / player_performances[past_game.away_batting_spot_6]["career_games"]
      feature_set.away_batting_spot_7_strikeout_rate_career = player_performances[past_game.away_batting_spot_7]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_7]["career_strikeouts"] / player_performances[past_game.away_batting_spot_7]["career_games"]
      feature_set.away_batting_spot_8_strikeout_rate_career = player_performances[past_game.away_batting_spot_8]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_8]["career_strikeouts"] / player_performances[past_game.away_batting_spot_8]["career_games"]
      feature_set.away_batting_spot_9_strikeout_rate_career = player_performances[past_game.away_batting_spot_9]["career_games"] == 0 ? 0 : player_performances[past_game.away_batting_spot_9]["career_strikeouts"] / player_performances[past_game.away_batting_spot_9]["career_games"]
    end

    feature_set.save

    performances.each do |perf|
      player = Player.find_by_id(perf.player_id)

      # career updates
      player_performances[player.retrosheet_id]["career_games"] += 1
      player_performances[player.retrosheet_id]["career_at_bats"] += perf.at_bats
      player_performances[player.retrosheet_id]["career_walks"] += perf.walks
      player_performances[player.retrosheet_id]["career_hits"] += perf.hits
      player_performances[player.retrosheet_id]["career_strikeouts"] += perf.strikeouts 
      player_performances[player.retrosheet_id]["career_total_bases"] += perf.total_bases                  
      
      player_performances[player.retrosheet_id]["at_bats_last_1_game"] << perf.at_bats
      player_performances[player.retrosheet_id]["at_bats_last_2_games"] << perf.at_bats
      player_performances[player.retrosheet_id]["at_bats_last_5_games"] << perf.at_bats
      player_performances[player.retrosheet_id]["at_bats_last_10_games"] << perf.at_bats
      player_performances[player.retrosheet_id]["at_bats_last_20_games"] << perf.at_bats
      
      player_performances[player.retrosheet_id]["at_bats_last_1_game"].shift
      player_performances[player.retrosheet_id]["at_bats_last_2_games"].shift
      player_performances[player.retrosheet_id]["at_bats_last_5_games"].shift
      player_performances[player.retrosheet_id]["at_bats_last_10_games"].shift
      player_performances[player.retrosheet_id]["at_bats_last_20_games"].shift

      player_performances[player.retrosheet_id]["walks_last_1_game"] << perf.walks
      player_performances[player.retrosheet_id]["walks_last_2_games"] << perf.walks
      player_performances[player.retrosheet_id]["walks_last_5_games"] << perf.walks
      player_performances[player.retrosheet_id]["walks_last_10_games"] << perf.walks
      player_performances[player.retrosheet_id]["walks_last_20_games"] << perf.walks
      
      player_performances[player.retrosheet_id]["walks_last_1_game"].shift
      player_performances[player.retrosheet_id]["walks_last_2_games"].shift
      player_performances[player.retrosheet_id]["walks_last_5_games"].shift
      player_performances[player.retrosheet_id]["walks_last_10_games"].shift
      player_performances[player.retrosheet_id]["walks_last_20_games"].shift

      player_performances[player.retrosheet_id]["hits_last_1_game"] << perf.hits
      player_performances[player.retrosheet_id]["hits_last_2_games"] << perf.hits
      player_performances[player.retrosheet_id]["hits_last_5_games"] << perf.hits
      player_performances[player.retrosheet_id]["hits_last_10_games"] << perf.hits
      player_performances[player.retrosheet_id]["hits_last_20_games"] << perf.hits
      
      player_performances[player.retrosheet_id]["hits_last_1_game"].shift
      player_performances[player.retrosheet_id]["hits_last_2_games"].shift
      player_performances[player.retrosheet_id]["hits_last_5_games"].shift
      player_performances[player.retrosheet_id]["hits_last_10_games"].shift
      player_performances[player.retrosheet_id]["hits_last_20_games"].shift

      player_performances[player.retrosheet_id]["strikeouts_last_1_game"] << perf.strikeouts
      player_performances[player.retrosheet_id]["strikeouts_last_2_games"] << perf.strikeouts
      player_performances[player.retrosheet_id]["strikeouts_last_5_games"] << perf.strikeouts
      player_performances[player.retrosheet_id]["strikeouts_last_10_games"] << perf.strikeouts
      player_performances[player.retrosheet_id]["strikeouts_last_20_games"] << perf.strikeouts
      
      player_performances[player.retrosheet_id]["strikeouts_last_1_game"].shift
      player_performances[player.retrosheet_id]["strikeouts_last_2_games"].shift
      player_performances[player.retrosheet_id]["strikeouts_last_5_games"].shift
      player_performances[player.retrosheet_id]["strikeouts_last_10_games"].shift
      player_performances[player.retrosheet_id]["strikeouts_last_20_games"].shift

      player_performances[player.retrosheet_id]["total_bases_last_1_game"] << perf.total_bases
      player_performances[player.retrosheet_id]["total_bases_last_2_games"] << perf.total_bases
      player_performances[player.retrosheet_id]["total_bases_last_5_games"] << perf.total_bases
      player_performances[player.retrosheet_id]["total_bases_last_10_games"] << perf.total_bases
      player_performances[player.retrosheet_id]["total_bases_last_20_games"] << perf.total_bases
      
      player_performances[player.retrosheet_id]["total_bases_last_1_game"].shift
      player_performances[player.retrosheet_id]["total_bases_last_2_games"].shift
      player_performances[player.retrosheet_id]["total_bases_last_5_games"].shift
      player_performances[player.retrosheet_id]["total_bases_last_10_games"].shift
      player_performances[player.retrosheet_id]["total_bases_last_20_games"].shift
    end
  end
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []

(1 .. 30).each do |i|
  addFeaturesAndLabel(i, DateTime.parse("20010101"), DateTime.parse("20120101"), training_examples, training_labels)
  puts "#{i}..."
end
=begin
puts "generating testing set...."
testing_examples = []
testing_labels = []

(1 .. 30).each do |i|
  addFeaturesAndLabel(i, DateTime.parse("20110101"), DateTime.parse("20120101"), testing_examples, testing_labels)
end
=end

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

def formatFeature(value)
  return (value > 0 ? 1 : 0)
end

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
    if feature.h2h_diff_1 == nil
      next
    else
      feature_set << formatFeature(feature.h2h_diff_1)
    end

    if feature.h2h_diff_2 == nil
      next
    else
      feature_set << formatFeature(feature.h2h_diff_2)
    end
    
    if feature.h2h_diff_3 == nil
      next
    else
      feature_set << formatFeature(feature.h2h_diff_3)
    end

    if feature.run_differentials_1 == nil or feature.opp_differentials_1 == nil
      next
    else
      feature_set << formatFeature(feature.run_differentials_1 - feature.opp_differentials_1)
    end

    if feature.run_differentials_2 == nil or feature.opp_differentials_2 == nil
      next
    else
      feature_set << formatFeature(feature.run_differentials_2 - feature.opp_differentials_2)
    end

    if feature.run_differentials_5 == nil or feature.opp_differentials_5 == nil
      next
    else
      feature_set << formatFeature(feature.run_differentials_5 - feature.opp_differentials_5)
    end

    if feature.run_differentials_10 == nil or feature.opp_differentials_10 == nil
      next
    else
      feature_set << formatFeature(feature.run_differentials_10 - feature.opp_differentials_10)
    end

    if feature.run_differentials_20 == nil or feature.opp_differentials_20 == nil
      next
    else
      feature_set << formatFeature(feature.run_differentials_20 - feature.opp_differentials_20)
    end

    if feature.win_differentials_1 == nil or feature.opp_win_differentials_1 == nil
      next
    else
      feature_set << formatFeature(feature.win_differentials_1 - feature.opp_win_differentials_1)
    end

    if feature.win_differentials_2 == nil or feature.opp_win_differentials_2 == nil
      next
    else
      feature_set << formatFeature(feature.win_differentials_2 - feature.opp_win_differentials_2)
    end

    if feature.win_differentials_5 == nil or feature.opp_win_differentials_5 == nil
      next
    else
      feature_set << formatFeature(feature.win_differentials_5 - feature.opp_win_differentials_5)
    end

    if feature.win_differentials_10 == nil or feature.opp_win_differentials_10 == nil
      next
    else
      feature_set << formatFeature(feature.win_differentials_10 - feature.opp_win_differentials_10)
    end

    if feature.win_differentials_20 == nil or feature.opp_win_differentials_20 == nil
      next
    else
      feature_set << formatFeature(feature.win_differentials_20 - feature.opp_win_differentials_20)
    end


    #feature_set << (feature.home_team_won ? 1 : 0)

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
addFeaturesAndLabel(DateTime.parse("20010101"), DateTime.parse("20100101"), training_examples, training_labels)


puts "generating testing set...."
testing_examples = []
testing_labels = []
addFeaturesAndLabel(DateTime.parse("20100101"), DateTime.parse("20110101"), testing_examples, testing_labels)


num_wins = training_labels.reduce(:+).to_f
prior = training_labels.reduce(:+).to_f / training_labels.size

num_features = (training_examples[0].size - 1)

x_count_win = []
x_count_loss = []
(0..(num_features)).each do |i|
  x_count_win << 1
  x_count_loss << 1
end


(0..num_features).each do |i|
  (0..training_examples.size - 1).each do |j|
    if training_examples[j][i] == 1
      if training_labels[j] == 1
        x_count_win[i] += 1
      else
        x_count_loss[i] += 1
      end
    end
  end
end

x_prob_win = x_count_win
x_prob_loss = x_count_loss

errors = 0
(0..num_features).each do |i|
  x_prob_win[i] = x_count_win[i]/(num_wins + 2)
  x_prob_loss[i] = x_count_loss[i]/(training_examples.size - num_wins + 2)
end

testing_examples.each_with_index do |test_vector, index|
  p_win = Math.log(prior)
  p_loss = Math.log(1 - prior)

  (0..num_features).each do |i|
    p_win += Math.log(test_vector[i] == 1 ? x_prob_win[i] : 1 - x_prob_win[i])
    p_loss += Math.log(test_vector[i] == 1 ? x_prob_loss[i] : 1 - x_prob_loss[i])
  end

  guess = 0
  if p_win > p_loss
    guess = 1
  end

  if guess != testing_labels[index]
    errors += 1
  end

end
puts "Errors: #{errors}"
puts "Error rate: #{(testing_labels.size - errors).to_f / testing_labels.size}"



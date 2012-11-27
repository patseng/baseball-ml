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
    if feature.h2h_diff_1 == nil
      next
    else
      feature_set << feature.h2h_diff_1
    end

    if feature.h2h_diff_2 == nil
      next
    else
      feature_set << feature.h2h_diff_2
    end
    
    if feature.h2h_diff_3 == nil
      next
    else
      feature_set << feature.h2h_diff_3
    end

    if feature.run_differentials_1 == nil or feature.opp_differentials_1 == nil
      next
    else
      feature_set << feature.run_differentials_1 - feature.opp_differentials_1
    end

    if feature.run_differentials_2 == nil or feature.opp_differentials_2 == nil
      next
    else
      feature_set << feature.run_differentials_2 - feature.opp_differentials_2
    end

    if feature.run_differentials_5 == nil or feature.opp_differentials_5 == nil
      next
    else
      feature_set << feature.run_differentials_5 - feature.opp_differentials_5
    end

    if feature.run_differentials_10 == nil or feature.opp_differentials_10 == nil
      next
    else
      feature_set << feature.run_differentials_10 - feature.opp_differentials_10
    end

    if feature.run_differentials_20 == nil or feature.opp_differentials_20 == nil
      next
    else
      feature_set << feature.run_differentials_20 - feature.opp_differentials_20
    end

    if feature.win_differentials_1 == nil or feature.opp_win_differentials_1 == nil
      next
    else
      feature_set << feature.win_differentials_1 - feature.opp_win_differentials_1
    end

    if feature.win_differentials_2 == nil or feature.opp_win_differentials_2 == nil
      next
    else
      feature_set << feature.win_differentials_2 - feature.opp_win_differentials_2
    end

    if feature.win_differentials_5 == nil or feature.opp_win_differentials_5 == nil
      next
    else
      feature_set << feature.win_differentials_5 - feature.opp_win_differentials_5
    end

    if feature.win_differentials_10 == nil or feature.opp_win_differentials_10 == nil
      next
    else
      feature_set << feature.win_differentials_10 - feature.opp_win_differentials_10
    end

    if feature.win_differentials_20 == nil or feature.opp_win_differentials_20 == nil
      next
    else
      feature_set << feature.win_differentials_20 - feature.opp_win_differentials_20
    end

    examples << feature_set
    labels << (feature.home_team_won ? 1 : -1)
  end
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []
addFeaturesAndLabel(DateTime.parse("20010101"), DateTime.parse("20110101"), training_examples, training_labels)

puts "generating testing set...."
testing_examples = []
testing_labels = []
addFeaturesAndLabel(DateTime.parse("20110101"), DateTime.parse("20120101"), testing_examples, testing_labels)

# =============================================================================
# train svm
# =============================================================================

problem = Libsvm::Problem.new
parameter = Libsvm::SvmParameter.new

parameter.cache_size = 1

parameter.eps = 0.001
parameter.c = 10

# Type can be LINEAR, POLY, RBF, SIGMOID
parameter.kernel_type = Libsvm::KernelType::LINEAR

training_examples = training_examples.map {|ary| Libsvm::Node.features(ary) }
problem.set_examples(training_labels, training_examples)

puts "training..."
model = Libsvm::Model.train(problem, parameter)

# =============================================================================
# find estimated error
# =============================================================================

puts "testing..."
hits = 0.0
misses = 0
testing_examples.each_with_index do |testing_example, i|
  test_example = Libsvm::Node.features(testing_example)
  pred = model.predict(test_example)
  if pred == testing_labels[i]
    hits += 1
  else
    misses += 1
  end
end

error = hits / (hits + misses)
puts error
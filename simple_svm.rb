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
    
=begin
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
=end

#=begin
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
#=end

    #feature_set << (feature.home_team_won ? 1 : -1)

    examples << feature_set
    labels << (feature.home_team_won ? 1 : -1)
  end
end



def rbfAccuracyGivenDataAndParameters(training_labels, training_examples, testing_labels, testing_examples, gamma, c)
  puts "Gamma = #{gamma}, C = #{c}"
  # =============================================================================
  # train svm
  # =============================================================================

  problem = Libsvm::Problem.new
  parameter = Libsvm::SvmParameter.new

  parameter.svm_type = Libsvm::SvmType::C_SVC
  parameter.nu = 0.5
  parameter.eps = 0.001

  parameter.cache_size = 100
  
  parameter.gamma = gamma.to_f
  parameter.c = c.to_f

  # Type can be LINEAR, POLY, RBF, SIGMOID
  parameter.kernel_type = Libsvm::KernelType::RBF

  training_examples = training_examples.map {|ary| Libsvm::Node.features(ary) }
  problem.set_examples(training_labels, training_examples)

  puts "\ttraining..."
  model = Libsvm::Model.train(problem, parameter)
  
  # =============================================================================
  # find estimated error
  # =============================================================================
  
  puts "\ttesting..."
  hits = 0.0
  misses = 0
  ones = 0
  testing_examples.each_with_index do |testing_example, i|
    test_example = Libsvm::Node.features(testing_example)
    pred = model.predict(test_example)
    if pred == 1
      ones += 1
    end
    if pred == testing_labels[i]
      hits += 1
    else
      misses += 1
    end
  end
  
  accuracy = hits / (hits + misses)
  puts "\tAccuracy: #{accuracy}"
  puts "\t1s: #{ones}"
  puts "\tTotal examples: #{hits + misses}"
  return accuracy
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

=begin
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
=end

# =============================================================================
# Grid Search:
# for RBF we do not know which (C, gamma) are best
# =============================================================================

gamma_exponents = (-12..-8).step(0.5) 
gammas = gamma_exponents.collect { |x| 2**x } # 

cs = (-1..4).step(0.5).collect { |x| 2**x }

best_accuracy = 0.0
best_gamma = nil
best_c = nil

File.open("peter-13-narrow-gridsearch2.out", 'w') do |f|  
  gammas.each do |gamma|
    cs.each do |c|  
      accuracy = rbfAccuracyGivenDataAndParameters(training_labels, training_examples, testing_labels, testing_examples, gamma, c)
      f.write("#{gamma}, #{c}, #{accuracy}\n")    
      if accuracy > best_accuracy
        best_accuracy = accuracy
        best_gamma = gamma
        best_c = c
      end
    end
  end
end

puts "#{best_accuracy} achieved with gamme = #{best_gamma} C=#{best_c}"

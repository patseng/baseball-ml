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

require './teamMap.rb'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# =============================================================================
# helper function
# =============================================================================

def addFeaturesAndLabel(home_team, away_team, earliest_date, latest_date, examples, labels)
  home_faceoffs = Game.where("home_team = ? and away_team = ? and game_date > ? and game_date <= ?", home_team, away_team, earliest_date, latest_date).order("game_date desc")
  away_faceoffs = Game.where("home_team = ? and away_team = ? and game_date > ? and game_date <= ?", away_team, home_team, earliest_date, latest_date).order("game_date desc")
  past_games = home_faceoffs.concat(away_faceoffs)
  past_games = past_games.sort {|game1, game2| game1.game_date <=> game2.game_date }

  if past_games.size < 3
    return
  end

  run_differentials = []
  past_games.each_with_index do |past_game, index|
    if past_game.home_team == home_team
      run_differentials << past_game.home_team_runs - past_game.away_team_runs
    else 
      run_differentials << past_game.away_team_runs - past_game.home_team_runs      
    end

    if run_differentials.size > 3
      run_differentials.shift
    end

    if past_games.size == index + 1
      return
    end

    game = past_games[index + 1]

    if game.home_team_runs > game.away_team_runs then y = 1 else y = -1 end

    if run_differentials.size == 3
      examples << run_differentials
      labels << y
    end
  end
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []
#=begin
File.open("features/1_run_differentials/training_examples.yaml", "r") do |object|
  training_examples = YAML::load(object)
end
File.open("features/1_run_differentials/training_labels.yaml", "r") do |object|
  training_labels = YAML::load(object)
end
#=end

=begin
(1 .. 30).each do |i|
  (i + 1 .. 30).each do |j|
    addFeaturesAndLabel(i, j, DateTime.parse("20010101"), DateTime.parse("20110101"), training_examples, training_labels)
  end
end


puts "writing training set to file..."
File.open("features/1_run_differentials/training_examples.yaml", "w") do |file|
  file.puts YAML::dump(training_examples)
end
File.open("features/1_run_differentials/training_labels.yaml", "w") do |file|
  file.puts YAML::dump(training_labels)
end
=end

puts "generating testing set...."
testing_examples = []
testing_labels = []
#=begin
File.open("features/1_run_differentials/testing_examples.yaml", "r") do |object|
  testing_examples = YAML::load(object)
end
File.open("features/1_run_differentials/testing_labels.yaml", "r") do |object|
  testing_labels = YAML::load(object)
end
#=end

=begin
(1 .. 30).each do |i|
  (i + 1 .. 30).each do |j|
    addFeaturesAndLabel(i, j, DateTime.parse("20110101"), DateTime.parse("20120101"), testing_examples, testing_labels)
  end
end

puts "writing testing set to file..."
File.open("features/1_run_differentials/testing_examples.yaml", "w") do |file|
  file.puts YAML::dump(testing_examples)
end
File.open("features/1_run_differentials/testing_labels.yaml", "w") do |file|
  file.puts YAML::dump(testing_labels)
end
=end

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
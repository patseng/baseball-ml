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

def addFeaturesAndLabel(game, examples, labels)
  home_faceoffs = Game.where("home_team = ? and away_team = ? and game_date <= ?", game.home_team, game.away_team, game.game_date - 1).order("game_date desc").limit(3)
  away_faceoffs = Game.where("home_team = ? and away_team = ? and game_date <= ?", game.away_team, game.home_team, game.game_date - 1).order("game_date desc").limit(3)
  past_games = home_faceoffs.concat(away_faceoffs)
  past_games = past_games.sort {|game1, game2| game2.game_date <=> game1.game_date }

  if past_games.size < 3
    return
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

  examples << run_differentials
  labels << y
end

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []
Game.where("game_date < ?", DateTime.parse("20010601")).each do |game|
  addFeaturesAndLabel(game, training_examples, training_labels)
end

puts "generating testing set...."
testing_examples = []
testing_labels = []
Game.where("game_date < ? and game_date > ?", DateTime.parse("20100601"), DateTime.parse("20100101")).each do |game|
  addFeaturesAndLabel(game, testing_examples, testing_labels)
end

# =============================================================================
# train svm
# =============================================================================

problem = Libsvm::Problem.new
parameter = Libsvm::SvmParameter.new

parameter.cache_size = 1

parameter.eps = 0.001
parameter.c = 10

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
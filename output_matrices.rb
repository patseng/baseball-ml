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
require "./ml_helper"
extend MLHelper;

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# =============================================================================
# Obtain training and testing set
# =============================================================================

puts "generating training set...."
training_examples = []
training_labels = []
# update this method if you want to train over a different set of features
addThirteenAndCareerFeaturesAndLabel(DateTime.parse("20080101"), DateTime.parse("20100101"), training_examples, training_labels)

puts "generating testing set...."
testing_examples = []
testing_labels = []
# update this method if you want to test over a different set of features
addThirteenAndCareerFeaturesAndLabel(DateTime.parse("20100101"), DateTime.parse("20110101"), testing_examples, testing_labels)

File.open("13_and_career_train_matrix.out", 'w') do |f|
  training_examples.each_with_index do |example, i|
    f.write(training_labels[i])
    example.each do |feature|
      f.write(',')
      f.write(feature)
    end
    f.write("\n")
  end
end

File.open("13_and_career_test_matrix.out", 'w') do |f|
  testing_examples.each_with_index do |example, i|
    f.write(testing_labels[i])
    example.each do |feature|
      f.write(',')
      f.write(feature)
    end
    f.write("\n")
  end
end
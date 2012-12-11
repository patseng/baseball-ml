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
                                    
File.open("heldout.out", "w") do |file|
  puts "Team Features (aka 13 features)"
  puts "generating training set...."
  training_examples = []
  training_labels = []
  addThirteenFeaturesAndLabel(DateTime.parse("20080101"), DateTime.parse("20100101"), training_examples, training_labels)      
  puts "generating testing set...."
  testing_examples = []
  testing_labels = []
  addThirteenFeaturesAndLabel(DateTime.parse("20110101"), DateTime.parse("20120101"), testing_examples, testing_labels)

  puts "feature_set size: #{testing_examples.first.size}"
  gamma = 2**-8
  c = 1/2
  accuracy = rbfAccuracyGivenDataAndParameters(training_labels, training_examples, 
                                      testing_labels, testing_examples, gamma, c)
  f.write("team features,#{accuracy.to)f}\n")
  
  puts "Momentum less Features"
  puts "generating training set...."
  training_examples = []
  training_labels = []
  addMomentumLessFeaturesAndLabel(DateTime.parse("20080101"), DateTime.parse("20100101"), training_examples, training_labels)      
  puts "generating testing set...."
  testing_examples = []
  testing_labels = []
  addMomentumLessFeaturesAndLabel(DateTime.parse("20110101"), DateTime.parse("20120101"), testing_examples, testing_labels)

  puts "feature_set size: #{testing_examples.first.size}"
  gamma = 2**-8
  c = 1/2
  accuracy = rbfAccuracyGivenDataAndParameters(training_labels, training_examples, 
                                      testing_labels, testing_examples, gamma, c)
  f.write("momentum less features,#{accuracy.to)f}\n")
  

end
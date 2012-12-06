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

puts "generating training set...."
training_examples = []
training_labels = []
# this method is in linear_ml_helper
addFeaturesAndLabel(DateTime.parse("20080101"), DateTime.parse("20100101"), training_examples, training_labels)      

puts "generating testing set...."
testing_examples = []
testing_labels = []
# this method is in linear_ml_helper
addFeaturesAndLabel(DateTime.parse("20100101"), DateTime.parse("20110101"), testing_examples, testing_labels)

# =============================================================================
# Grid Search: 
# *****************************************************************************
# README **********************************************************************
# *****************************************************************************
# 1) Replace and find all instances of andy with your name
# 2) Pick different areas of R2 to perform gridsearch over
# =============================================================================

# TODO - modify C values
# C = [2^-5, 2^-3,..., 2^15]
andy_cs = (-5..15).step(2).collect { |x| 2**x }

best_accuracy = 0.0
best_c = nil

# perform grid search
File.open("no-momentum-linear-gridsearch.out", 'w') do |f|  
  andy_cs.each do |c|
    # this method is in ml_helper
    accuracy = linearAccuracyGivenDataAndParameters(training_labels,
      training_examples, testing_labels, testing_examples, c)
                                        
    f.write("#{c.to_f}, #{accuracy}\n")    
    if accuracy > best_accuracy
      best_accuracy = accuracy
      best_c = c
    end
  end
end

puts "#{best_accuracy} achieved with C=#{best_c.to_f}"

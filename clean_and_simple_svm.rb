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
# this method is in ml_helper
addFeaturesAndLabel(DateTime.parse("20080101"), DateTime.parse("20100101"), training_examples, training_labels)      

puts "generating testing set...."
testing_examples = []
testing_labels = []
# this method is in ml_helper
addFeaturesAndLabel(DateTime.parse("20100101"), DateTime.parse("20110101"), testing_examples, testing_labels)

# =============================================================================
# Grid Search: 
# *****************************************************************************
# README **********************************************************************
# *****************************************************************************
# 1) Replace and find all instances of peter with your name
# 2) Pick different areas of R2 to perform gridsearch over
# for RBF we do not know which (C, gamma) are best
# =============================================================================


# TODO - modify gamma values
# gammas = [2^-15, 2^-13, ..., 2^3]
peter_gamma_exponents = (-15..3).step(2) 
peter_gammas = gamma_exponents.collect { |x| 2**x } # 

# TODO - modify C values
# C = [2^-5, 2^-3,..., 2^15]
peter_cs = (-5..15).step(2).collect { |x| 2**x }

best_accuracy = 0.0
best_gamma = nil
best_c = nil

while true
  
end

# perform grid search
File.open("peter-gridsearch.out", 'w') do |f|  
  peter_gammas.each do |gamma|
    peter_cs.each do |c|
      # this method is in ml_helper
      accuracy = rbfAccuracyGivenDataAndParameters(training_labels, training_examples, 
                                          testing_labels, testing_examples, gamma, c)
                                          
      f.write("#{gamma}, #{c}, #{accuracy}\n")    
      if accuracy > best_accuracy
        best_accuracy = accuracy
        best_gamma = gamma
        best_c = c
      end
    end
  end
end

puts "#{best_accuracy} achieved with gamma = #{best_gamma} C=#{best_c}"

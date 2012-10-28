require 'rubygems'
require 'active_record'
require 'yaml'
require './models/player.rb'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

puts Player.count

player_example = Player.new({:player_number => 1, :batting_average => 0.23})
player_example.save

puts Player.count
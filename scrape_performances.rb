require 'rubygems'
require 'active_record'
require 'yaml'
require 'CSV'
require 'debugger'
require 'date'

require './models/game.rb'
require './models/player.rb'
require './models/performance.rb'

require './teamMap.rb'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

def parseEVA(file_path)
  # this opens the csv at the file path at iterates over the rows
  current_game = nil
  game_date = nil
  
  playerToPerformanceHash = {}
  begin    
    CSV.foreach(file_path) do |row|
      delimeter = row[0]
      case delimeter
      when 'info'  
        second_token = row[1]
        if second_token == 'date'
          game_date = DateTime.parse(row[2])
        elsif second_token == 'number'
          current_game = Game.find_by_game_date_and_game_number(game_date, row[2].to_i)
        end
      when 'id'
        if !playerToPerformanceHash.empty?
          # save all of the performances
          playerToPerformanceHash.each_value do |performance|
            performance.save
          end
        end
        playerToPerformanceHash = {}
      when 'start'
        playerName = row[1]
        playerToPerformanceHash[playerName] ||= Performance.new
        # performance is a reference not a copy
        performance = playerToPerformanceHash[playerName]
        performance[:did_start] = true
        performance[:player_id] = Player.find_by_retrosheet_id(playerName).id
        performance[:game_id] = current_game.id
      when 'play'
        # get performance object
        playerName = row[3]
        performance = playerToPerformanceHash[playerName] # performance is a reference not a copy
        
        regex = /[^\/]*/
        at_bat_performance = row[6].match(regex)[0].to_s
        option = at_bat_performance[0]
        case option
        when 'S'
          # single
          if at_bat_performance.length >= 2
            second_option = at_bat_performance[1]
            case second_option
            when 'B'
              # stolen base, do nothing
            else
              # single
              performance.at_bats += 1
              performance.hits += 1
              performance.total_bases += 1
            end
          else
            performance.at_bats += 1
            performance.hits += 1
            performance.total_bases += 1
          end
        when 'D'

          if at_bat_performance.length >= 2
            second_option = at_bat_performance[1]
            case second_option
            when 'I'
              # defensive interference, do nothing
            else
              # double
              performance.at_bats += 1
              performance.hits += 1
              performance.total_bases += 2
            end
          else
            performance.at_bats += 1
            performance.hits += 1
            performance.total_bases += 2
          end
          
        when 'T'
          # triple
          
          performance.at_bats += 1
          performance.hits += 1
          performance.total_bases += 3
          
        when 'H'
          if at_bat_performance.size >= 2
            second_option = at_bat_performance[1] 
            case second_option
            when 'P'
              # hit by pitch
              performance.walks += 1
            else
              # homerun
              performance.at_bats += 1
              performance.hits += 1
              performance.total_bases += 4
            end
          else
            # homerun
            performance.at_bats += 1
            performance.hits += 1
            performance.total_bases += 4
          end  
        when 'W'
          # walk
          if at_bat_performance.length >= 2
            second_option = at_bat_performance[1]
            case second_option
            when 'P'
              # wild pitch, do nothing
            else
              # walk
              performance.walks += 1
            end
          else
            performance.walks += 1
          end

        when 'I'
          # intentional walk
          performance.walks += 1          
        when 'K'
          performance.strikeouts += 1
          performance.at_bats += 1
        when 'F'
          # multi-option
          second_option = at_bat_performance[1]
          case second_option
          when 'C'
            # Fielder's choice
            performance.at_bats += 1
          else
            # do nothing
          end
          
        else
          # check if number here
          if option.to_i != 0
            performance.at_bats += 1
          end
        end
        
        playerToPerformanceHash[playerName] ||= Performance.new
        # performance is a reference not a copy
        performance = playerToPerformanceHash[playerName]
        performance[:did_start] = true
        performance[:player_id] = Player.find_by_retrosheet_id(playerName).id
        performance[:game_id] = current_game.id
      when 'sub'
        playerName = row[1]
        playerToPerformanceHash[playerName] ||= Performance.new
        # performance is a reference not a copy
        performance = playerToPerformanceHash[playerName]
        performance[:did_start] = false
        performance[:player_id] = Player.find_by_retrosheet_id(playerName).id
        performance[:game_id] = current_game.id
      else
      end
    end
  rescue CSV::MalformedCSVError => er
    puts er.message
  end
  
  playerToPerformanceHash.each_value do |performance|
    performance.save
  end
  
end

# this iterates over every file/directory in raw_data (which we know is a directory)
Dir.entries('./raw_data').each do |dir|
  # grabs all the files (.ROS, .EVA, .EVN) in the subdirectory
  file_names = Dir.entries("./raw_data/#{dir}")
  file_names.each do |file_name|
    if file_name =~ /.*\.EV(A|N)/
      puts "./raw_data/#{dir}/#{file_name}"
      parseEVA("./raw_data/#{dir}/#{file_name}")
    end
  end
end
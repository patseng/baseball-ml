
require 'debugger'

File.open("peter-all-narrow-gridsearch.out", 'w') do |output|  
  File.open("narrow_gridsearch.txt", "r") do |file|
    gamma = 0
    c = 0
    accuracy = 0
    while (line = file.gets)
      regex = /Gamma = (0.[0-9]*), C = ([0-9].[0-9]*)/
      matchData = regex.match(line)
      if matchData
        gamma = matchData[1]
        c = matchData[2]
      else
        regex = /Accuracy: ([0-9].[0-9]*)/
        matchData = regex.match(line)
        if matchData
          accuracy = matchData[1]
          output.write("#{gamma},#{c},#{accuracy}\n")    
        end
      end
    end
  end
end
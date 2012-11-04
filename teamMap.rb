class TeamMap
  @teamNamesToInt = Hash.new

  @teamNamesToInt['ANA'] = 1
  @teamNamesToInt['ARI'] = 2
  @teamNamesToInt['ATL'] = 3
  @teamNamesToInt['BAL'] = 4
  @teamNamesToInt['BOS'] = 5
  @teamNamesToInt['CHA'] = 6
  @teamNamesToInt['CHN'] = 7
  @teamNamesToInt['CIN'] = 8
  @teamNamesToInt['CLE'] = 9
  @teamNamesToInt['COL'] = 10
  @teamNamesToInt['DET'] = 11
  @teamNamesToInt['FLO'] = 12
  @teamNamesToInt['HOU'] = 13
  @teamNamesToInt['KCA'] = 14
  @teamNamesToInt['LAN'] = 15
  @teamNamesToInt['MIL'] = 16
  @teamNamesToInt['MIN'] = 17
  @teamNamesToInt['NYA'] = 18
  @teamNamesToInt['NYN'] = 19
  @teamNamesToInt['OAK'] = 20
  @teamNamesToInt['PHI'] = 21
  @teamNamesToInt['PIT'] = 22
  @teamNamesToInt['SDN'] = 23
  @teamNamesToInt['SEA'] = 24
  @teamNamesToInt['SFN'] = 25
  @teamNamesToInt['SLN'] = 26
  @teamNamesToInt['TBA'] = 27
  @teamNamesToInt['TEX'] = 28
  @teamNamesToInt['TOR'] = 29
  @teamNamesToInt['WAS'] = 30

  teamIntsToName = Hash.new

  @teamNamesToInt.each do |k, v|
  	teamIntsToName[v] = k
  end
  
  def self.teamNamesToInt
    @teamNamesToInt
  end
end
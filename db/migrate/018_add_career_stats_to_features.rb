class AddCareerStatsToFeatures < ActiveRecord::Migration
  def change
     add_column :features, :home_batting_spot_1_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_2_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_3_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_4_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_5_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_6_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_7_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_8_walks_per_game_career, :integer
     add_column :features, :home_batting_spot_9_walks_per_game_career, :integer

     add_column :features, :away_batting_spot_1_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_2_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_3_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_4_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_5_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_6_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_7_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_8_walks_per_game_career, :integer
     add_column :features, :away_batting_spot_9_walks_per_game_career, :integer

     add_column :features, :home_batting_spot_1_batting_percentage_career, :float
     add_column :features, :home_batting_spot_2_batting_percentage_career, :float
     add_column :features, :home_batting_spot_3_batting_percentage_career, :float
     add_column :features, :home_batting_spot_4_batting_percentage_career, :float
     add_column :features, :home_batting_spot_5_batting_percentage_career, :float
     add_column :features, :home_batting_spot_6_batting_percentage_career, :float
     add_column :features, :home_batting_spot_7_batting_percentage_career, :float
     add_column :features, :home_batting_spot_8_batting_percentage_career, :float
     add_column :features, :home_batting_spot_9_batting_percentage_career, :float

     add_column :features, :away_batting_spot_1_batting_percentage_career, :float
     add_column :features, :away_batting_spot_2_batting_percentage_career, :float
     add_column :features, :away_batting_spot_3_batting_percentage_career, :float
     add_column :features, :away_batting_spot_4_batting_percentage_career, :float
     add_column :features, :away_batting_spot_5_batting_percentage_career, :float
     add_column :features, :away_batting_spot_6_batting_percentage_career, :float
     add_column :features, :away_batting_spot_7_batting_percentage_career, :float
     add_column :features, :away_batting_spot_8_batting_percentage_career, :float
     add_column :features, :away_batting_spot_9_batting_percentage_career, :float

     add_column :features, :home_batting_spot_1_OPS_career, :float
     add_column :features, :home_batting_spot_2_OPS_career, :float
     add_column :features, :home_batting_spot_3_OPS_career, :float
     add_column :features, :home_batting_spot_4_OPS_career, :float
     add_column :features, :home_batting_spot_5_OPS_career, :float
     add_column :features, :home_batting_spot_6_OPS_career, :float
     add_column :features, :home_batting_spot_7_OPS_career, :float
     add_column :features, :home_batting_spot_8_OPS_career, :float
     add_column :features, :home_batting_spot_9_OPS_career, :float

     add_column :features, :away_batting_spot_1_OPS_career, :float
     add_column :features, :away_batting_spot_2_OPS_career, :float
     add_column :features, :away_batting_spot_3_OPS_career, :float
     add_column :features, :away_batting_spot_4_OPS_career, :float
     add_column :features, :away_batting_spot_5_OPS_career, :float
     add_column :features, :away_batting_spot_6_OPS_career, :float
     add_column :features, :away_batting_spot_7_OPS_career, :float
     add_column :features, :away_batting_spot_8_OPS_career, :float
     add_column :features, :away_batting_spot_9_OPS_career, :float

     add_column :features, :home_batting_spot_1_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_2_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_3_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_4_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_5_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_6_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_7_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_8_strikeout_rate_career, :float
     add_column :features, :home_batting_spot_9_strikeout_rate_career, :float

     add_column :features, :away_batting_spot_1_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_2_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_3_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_4_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_5_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_6_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_7_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_8_strikeout_rate_career, :float
     add_column :features, :away_batting_spot_9_strikeout_rate_career, :float
   end
end

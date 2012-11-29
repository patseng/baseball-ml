class AddBattingOrderToGames < ActiveRecord::Migration
  def change
     add_column :games, :home_batting_spot_1, :string
     add_column :games, :home_batting_spot_2, :string
     add_column :games, :home_batting_spot_3, :string
     add_column :games, :home_batting_spot_4, :string
     add_column :games, :home_batting_spot_5, :string
     add_column :games, :home_batting_spot_6, :string
     add_column :games, :home_batting_spot_7, :string
     add_column :games, :home_batting_spot_8, :string
     add_column :games, :home_batting_spot_9, :string

     add_column :games, :away_batting_spot_1, :string
     add_column :games, :away_batting_spot_2, :string
     add_column :games, :away_batting_spot_3, :string
     add_column :games, :away_batting_spot_4, :string
     add_column :games, :away_batting_spot_5, :string
     add_column :games, :away_batting_spot_6, :string
     add_column :games, :away_batting_spot_7, :string
     add_column :games, :away_batting_spot_8, :string
     add_column :games, :away_batting_spot_9, :string
   end
end

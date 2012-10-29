class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :home_team
      t.string :away_team
      t.boolean :home_team_won
      t.float :temperature
      t.boolean :day_game
      t.datetime :game_date
      t.boolean :used_designated_hitter
      t.float :wind_speed
      
      t.timestamps
    end
  end
end

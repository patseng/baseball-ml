class AddDoubleHeaderInfoToGames < ActiveRecord::Migration
  def change
    add_column :games, :game_number, :integer
  end
end

class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :player_id, :null => false
      t.integer :batting_style, :default => 0 # left = -1, both = 0, right = 1
      t.string :player_name
      t.timestamps
    end
  end
end

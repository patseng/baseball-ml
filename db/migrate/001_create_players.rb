class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :player_number, default: 0
      t.float :batting_average
      t.timestamps
    end
  end
end

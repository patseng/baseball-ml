class RandomStuff < ActiveRecord::Migration
  def change
     rename_column :players, :player_id, :retrosheet_id
     add_index :players, :retrosheet_id
   end
end

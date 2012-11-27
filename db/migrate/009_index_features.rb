class IndexFeatures < ActiveRecord::Migration
  def change
     add_index :features, :game_id
   end
end

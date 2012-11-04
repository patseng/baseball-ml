class CreatePerformances < ActiveRecord::Migration
  def change
     create_table :performances do |t|
       
       t.integer :game_id
       t.integer :player_id
       t.integer :at_bats
       t.integer :hits
       t.integer :walks
       t.integer :strikeouts
       t.integer :total_bases
       
       t.timestamps
     end
   end
end

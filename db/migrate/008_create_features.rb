class CreateFeatures < ActiveRecord::Migration
  def change
     create_table :features do |t|
       
       t.integer :game_id
       t.integer :h2h_diff_1
       t.integer :h2h_diff_2
       t.integer :h2h_diff_3

       t.boolean :home_team_won

       t.timestamps
     end
   end
end

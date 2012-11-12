class AddPlayerStartToPerformances < ActiveRecord::Migration
  def change
     add_column :performances, :did_start, :boolean
   end
end

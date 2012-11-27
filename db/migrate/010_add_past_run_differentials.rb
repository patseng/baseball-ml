class AddPastRunDifferentials < ActiveRecord::Migration
  def change
    add_column :features, :run_differentials_1, :float
    add_column :features, :run_differentials_2, :float
    add_column :features, :run_differentials_5, :float
    add_column :features, :run_differentials_10, :float
    add_column :features, :run_differentials_20, :float

    add_column :features, :opp_differentials_1, :float
    add_column :features, :opp_differentials_2, :float
    add_column :features, :opp_differentials_5, :float
    add_column :features, :opp_differentials_10, :float
    add_column :features, :opp_differentials_20, :float
  end
end

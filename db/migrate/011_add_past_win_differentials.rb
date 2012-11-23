class AddPastWinDifferentials < ActiveRecord::Migration
  def change
    add_column :features, :win_differentials_1, :int
    add_column :features, :win_differentials_2, :int
    add_column :features, :win_differentials_5, :int
    add_column :features, :win_differentials_10, :int
    add_column :features, :win_differentials_20, :int

    add_column :features, :opp_win_differentials_1, :int
    add_column :features, :opp_win_differentials_2, :int
    add_column :features, :opp_win_differentials_5, :int
    add_column :features, :opp_win_differentials_10, :int
    add_column :features, :opp_win_differentials_20, :int
  end
end

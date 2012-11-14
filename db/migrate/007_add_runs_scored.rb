class AddRunsScored < ActiveRecord::Migration
  def change
    add_column :games, :home_team_runs, :integer
    add_column :games, :away_team_runs, :integer
  end
end

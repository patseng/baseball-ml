class Player < ActiveRecord::Base
  validates_uniqueness_of :player_id
end
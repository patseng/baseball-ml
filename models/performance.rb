class Performance < ActiveRecord::Base
  after_initialize :defaults
  
  def defaults
    unless persisted?
      self.at_bats ||= 0
      self.hits ||= 0
      self.walks ||= 0    
      self.strikeouts ||= 0      
      self.total_bases ||= 0      
    end
  end
end
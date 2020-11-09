class UsageReport < ApplicationRecord
  def voters_count=(val)
    self.stances_count = val
  end
  
  def voters_count
    self.stances_count
  end
end

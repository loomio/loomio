class Cohort < ActiveRecord::Base
  has_many :groups

  def groups_count
    groups.count
  end
end

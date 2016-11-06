class Cohort < ActiveRecord::Base
  has_many :groups

  def organisations
    groups.where('parent_id IS NULL')
  end

end

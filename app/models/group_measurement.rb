class GroupMeasurement < ActiveRecord::Base
  scope :age_less_than, -> (max_age) { where('(period_end_on - groups.created_at::date) < ?', max_age) }
  belongs_to :group

  def age
    ( period_end_on  - group.created_at.to_date ).to_i
  end
end

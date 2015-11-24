class Subscription < ActiveRecord::Base
  has_one :group
  validates :kind, presence: true
  validates :group, presence: true
  validates_inclusion_of :kind, in: ['trial', 'gift', 'paid']

  delegate :id, to: :group, prefix: true, allow_nil: true

  def self.new_trial
    self.new(kind: 'trial', expires_at: 30.days.from_now.to_date)
  end

  def group_id=(id)
    self.group = Group.find(id)
  end

end

class Subscription < ApplicationRecord
  has_many :groups
  belongs_to :owner, class_name: 'User'

  def self.for(group)
    group.subscription || begin
      group.subscription = Subscription.new
      group.save
      group.subscription
    end
  end

  def plan=(value)
    self['plan'] = value.to_s.underscore
  end

  def is_active?
    ['active', 'trialing'].include? self.state
  end
end

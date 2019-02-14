class Subscription < ApplicationRecord
  has_many :groups
  belongs_to :owner, class_name: 'User'

  def plan=(value)
    self['plan'] = value.to_s.underscore
  end
end

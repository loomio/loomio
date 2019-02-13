class Subscription < ApplicationRecord
  has_many :groups
  belongs_to :owner, class_name: 'User'
end

class NetworkMembershipRequest < ActiveRecord::Base
  belongs_to :group
  belongs_to :network
  belongs_to :requestor, class_name: 'User'
  belongs_to :responder, class_name: 'User'

  scope :pending, -> { where('approved IS NULL') }
  scope :not_pending, -> { where('approved IS NOT NULL') }
end

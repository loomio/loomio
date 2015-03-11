class NetworkMembership < ActiveRecord::Base
  belongs_to :network
  belongs_to :group
end
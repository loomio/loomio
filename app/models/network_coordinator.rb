class NetworkCoordinator < ActiveRecord::Base
  belongs_to :network
  belongs_to :coordinator, class_name: 'User'
end
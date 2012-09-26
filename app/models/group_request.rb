class GroupRequest < ActiveRecord::Base
  attr_accessible :admin_email, :description, :expected_size, :name
end

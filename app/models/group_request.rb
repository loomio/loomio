class GroupRequest < ActiveRecord::Base
  attr_accessible :admin_email, :description, :expected_size, :member_emails, :name
end

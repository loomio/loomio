class Invitation < ActiveRecord::Base
  attr_accessible :access_level, :group_id, :inviter_id, :recipient_email
end

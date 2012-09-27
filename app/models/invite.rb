class Invite < ActiveRecord::Base
  belongs_to :inviter
  attr_accessible :recipient_email, :token
end

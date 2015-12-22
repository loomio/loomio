class UserDeactivationResponse < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :body
end

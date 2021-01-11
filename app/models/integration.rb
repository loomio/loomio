class Integration < ApplicationRecord
  extend HasTokens
  initialized_with_token :token

  validates_presence_of :group_id
  validates_presence_of :actor_id
  validates_presence_of :name
  validates_presence_of :token
end

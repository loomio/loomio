class UserDeactivationResponse < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :body

  EventBus.listen('user_deactivate') { |user, actor, params| create(user: user, body: params[:deactivation_response]) }
end

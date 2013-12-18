class AngularSupportController < ApplicationController
  before_filter :prevent_production_destruction

  USER_PARAMS = {name: 'Patrick Swayze',
                 email: 'patrick_swayze@loomio.org',
                 password: 'gh0st'}

  GROUP_NAME = 'Dirty Dancing Shoes'

  DISCUSSION_TITLE = 'What size are you?'

  def log_in_and_redirect_to_discussion
    reset_database
    sign_in user = User.where(email: USER_PARAMS[:email]).first
    discussion = Discussion.where(title: DISCUSSION_TITLE).first
    redirect_to "http://localhost:8000/discussions/#{discussion.id}"
  end

  private
  def prevent_production_destruction
    raise "No way!" if Rails.env.production?
  end
  
  def reset_database
    User.where(email: USER_PARAMS[:email]).first.try(:destroy)
    Group.where(name: GROUP_NAME).first.try(:destroy)

    user = User.create!(USER_PARAMS)
    group = Group.create!(name: GROUP_NAME, privacy: 'private')
    Discussion.create!(title: DISCUSSION_TITLE, group: group, author: user)

    group.add_member! user
  end
end

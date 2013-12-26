class AngularSupportController < ApplicationController
  before_filter :prevent_production_destruction

  USER_PARAMS = {name: 'Patrick Swayze',
                 email: 'patrick_swayze@loomio.org',
                 password: 'gh0st'}

  COMMENTER_PARAMS = {name: 'Jennifer Grey',
                      email: 'jennifer_grey@loomio.org',
                      password: 'gh0st'}

  GROUP_NAME = 'Dirty Dancing Shoes'

  DISCUSSION_TITLE = 'What star sign are you?'

  def setup_for_add_comment
    reset_database
    sign_in patrick
    redirect_to_discussion
  end

  def setup_for_like_comment
    reset_database
    sign_in patrick

    jennifer = User.create!(COMMENTER_PARAMS)

    MembershipService.add_users_to_group(group: testing_group,
                                         users: [jennifer],
                                         inviter: patrick)

    DiscussionService.add_comment Comment.new(author: jennifer, body: 'Hi Patrick, lets go dancing')

    redirect_to_discussion
  end

  private
  def prevent_production_destruction
    raise "No way!" if Rails.env.production?
  end

  def redirect_to_discussion
    redirect_to "http://localhost:8000/discussions/#{testing_discussion.id}"
  end

  def jennifer

  end

  def patrick
    User.where(email: 'patrick_swayze@loomio.org').first
  end

  def testing_group
    Group.where(name: GROUP_NAME).first
  end

  def testing_discussion
    testing_group.discussions.first
  end

  def reset_database
    if testing_group.present?
      testing_group.users.each(&:destroy)
      testing_group.destroy
    end

    user = User.create!(USER_PARAMS)
    group = Group.create!(name: GROUP_NAME, privacy: 'private')
    group.add_member! user

    Discussion.create!(title: DISCUSSION_TITLE, group: group, author: user)
  end
end

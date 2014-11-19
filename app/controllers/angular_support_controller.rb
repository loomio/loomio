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

  def connect_private_pub
  end

  def boot
    render file: Rails.root.join('public', 'angular.html'), layout: false
  end

  def setup_for_add_comment
    reset_database
    sign_in patrick
    redirect_to_discussion
  end

  def setup_for_like_comment
    reset_database
    sign_in patrick


    CommentService.create(comment: Comment.new(author: jennifer,
                                      discussion: testing_discussion,
                                      body: 'Hi Patrick, lets go dancing'), actor: jennifer)

    redirect_to_discussion
  end

  def setup_for_vote_on_proposal
    reset_database
    sign_in patrick

    MotionService.create(comment: Motion.new(author: jennifer,
                                             name: 'lets go hiking',
                                             closing_at: 3.days.from_now,
                                             discussion: testing_discussion),
                        actor: jennifer)


    redirect_to_discussion
  end

  private
  def prevent_production_destruction
    raise "No way!" if Rails.env.production?
  end

  def redirect_to_discussion
    redirect_to "http://localhost:8000/discussions/#{testing_discussion.key}"
  end

  def patrick
    User.where(email: USER_PARAMS[:email]).first
  end

  def jennifer
    User.where(email: COMMENTER_PARAMS[:email]).first
  end

  def testing_group
    Group.where(name: GROUP_NAME).first
  end

  def testing_discussion
    testing_group.discussions.first
  end

  def reset_database
    User.where(email: [USER_PARAMS[:email], COMMENTER_PARAMS[:email]]).each(&:destroy)

    if testing_group.present?
      testing_group.users.each(&:destroy)
      testing_group.destroy
    end

    patrick = User.create!(USER_PARAMS)
    jennifer = User.create!(COMMENTER_PARAMS)

    group = Group.create!(name: GROUP_NAME, privacy: 'private')

    group.add_member! patrick
    group.add_member! jennifer

    patrick.reload
    jennifer.reload
    group.reload

    Discussion.create!(title: DISCUSSION_TITLE, group: group, author: jennifer, private: true)
  end
end

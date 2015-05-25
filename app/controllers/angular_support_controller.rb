class AngularSupportController < ApplicationController
  around_filter :ensure_testing_environment

  USER_PARAMS = {name: 'Patrick Swayze',
                 email: 'patrick_swayze@loomio.org',
                 username: 'patrickswayze',
                 password: 'gh0stmovie',
                 angular_ui_enabled: true}

  COMMENTER_PARAMS = {name: 'Jennifer Grey',
                      email: 'jennifer_grey@loomio.org',
                      username: 'jennifergrey',
                      password: 'gh0stmovie',
                      angular_ui_enabled: true}

  INVITEE_PARAMS = {name: 'Max Von Sydow',
                    email: 'max@loomio.org',
                    password: 'gh0stmovie',
                    username: 'mingthemerciless',
                    angular_ui_enabled: true}

  GROUP_NAME = 'Dirty Dancing Shoes'
  OTHER_GROUP_NAME = 'Wendigo Winnebagos'

  DISCUSSION_TITLE = 'What star sign are you?'

  def discussion_url(discussion)
    "http://localhost:8000/d/#{discussion.key}/"
  end

  def group_url(group)
    "http://localhost:8000/g/#{group.key}/"
  end

  def connect_private_pub
  end

  def setup_for_invite_people
    reset_database
    sign_in patrick
    testing_group.update! members_can_add_members: true
    introduce_patrick_to_max

    redirect_to group_url(testing_group)
  end

  def setup_for_add_comment
    reset_database
    sign_in patrick
    redirect_to discussion_url(testing_discussion)
  end

  def setup_for_like_comment
    reset_database
    sign_in patrick


    CommentService.create(comment: Comment.new(author: jennifer,
                                      discussion: testing_discussion,
                                      body: 'Hi Patrick, lets go dancing'), actor: jennifer)

    redirect_to discussion_url(testing_discussion)
  end

  def setup_for_vote_on_proposal
    reset_database
    sign_in patrick

    MotionService.create(motion: Motion.new(name: 'lets go hiking',
                                            closing_at: 3.days.from_now,
                                            discussion: testing_discussion),
                        actor: patrick)


    redirect_to discussion_url(testing_discussion)
  end

  def setup_all_notifications
    reset_database
    sign_in patrick

    #'comment_liked'
    comment = Comment.new(discussion: testing_discussion, body: 'I\'m rather likeable')
    new_comment_event = CommentService.create(comment: comment, actor: patrick)
    comment_liked_event = CommentService.like(comment: comment, actor: jennifer)

    #'motion_closing_soon'
    motion = Motion.new(name: 'lets go hiking',
                        closing_at: 1.days.from_now,
                        discussion: testing_discussion)
    motion_created_event = MotionService.create(motion: motion,
                                                actor: jennifer)
    closing_soon_event = Events::MotionClosingSoon.publish!(motion)

    #'motion_outcome_created'
    outcome_event = MotionService.create_outcome(motion: motion,
                                                 params: {outcome: 'Were going hiking tomorrow'},
                                                 actor: jennifer)

    #'comment_replied_to'
    reply_comment = Comment.new(discussion: testing_discussion,
                                body: 'I agree with you', parent: comment)
    CommentService.create(comment: reply_comment, actor: jennifer)

    #'user_mentioned'
    comment = Comment.new(discussion: testing_discussion, body: 'hey @patrickswayze you look great in that tuxeido')
    CommentService.create(comment: comment, actor: jennifer)

    #'membership_requested',
    membership_request = MembershipRequest.new(name: 'The Ghost', email: 'boooooo@invisible.co', group: testing_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: LoggedOutUser.new)

    #'membership_request_approved',
    another_group = Group.new(name: 'Stars of the 90\'s', is_visible_to_public: true)
    GroupService.create(group: another_group, actor: jennifer)
    membership_request = MembershipRequest.new(requestor: patrick, group: another_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: patrick)
    approval_event = MembershipRequestService.approve(membership_request: membership_request, actor: jennifer)

    #'user_added_to_group',
    #notify patrick that he has been added to jens group
    another_group = Group.new(name: 'Planets of the 80\'s')
    GroupService.create(group: another_group, actor: jennifer)
    MembershipService.add_users_to_group(users: [patrick], group: another_group, inviter: jennifer, message: 'join in')

    redirect_to discussion_url(testing_discussion)
  end

  private

  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
    tmp, Rails.env = Rails.env, 'test'
    yield
    Rails.env = tmp
  end

  def patrick
    User.find_by_email USER_PARAMS[:email]
  end

  def jennifer
    User.find_by_email COMMENTER_PARAMS[:email]
  end

  def max
    User.find_by_email INVITEE_PARAMS[:email]
  end

  def testing_group
    Group.find_by_name GROUP_NAME
  end

  def other_testing_group
    Group.find_by_name OTHER_GROUP_NAME
  end

  def testing_discussion
    testing_group.discussions.first
  end

  def introduce_patrick_to_max
    group = Group.create! name: OTHER_GROUP_NAME
    group.add_member! patrick
    group.add_member! max
  end

  def reset_database
    User.delete_all
    Group.delete_all

    patrick = User.create!(USER_PARAMS)
    jennifer = User.create!(COMMENTER_PARAMS)
    max = User.create!(INVITEE_PARAMS)

    group = Group.create!(name: GROUP_NAME,
                          membership_granted_upon: 'approval',
                          is_visible_to_public: true,
                          is_visible_to_parent_members: false)
    group.add_admin! patrick
    group.add_member! jennifer

    Discussion.create!(title: DISCUSSION_TITLE, group: group, author: jennifer, private: true)
  end
end

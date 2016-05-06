module Development::NintiesMoviesHelper
  # try to just return objects here. Don't knit them together. Leave that for
  # the development controller action to do if possible
  def patrick
    @patrick ||= User.find_by_email('patrick_swayze@example.com') ||
                 User.create!(name: 'Patrick Swayze',
                              email: 'patrick_swayze@example.com',
                              is_admin: true,
                              username: 'patrickswayze',
                              password: 'gh0stmovie',
                              detected_locale: 'en',
                              angular_ui_enabled: true)
  end

  def patricks_contact
    if patrick.contacts.empty?
      patrick.contacts.create(name: 'Keanu Reeves',
                              email: 'keanu@example.com',
                              source: 'gmail')
    end
  end

  def jennifer
    @jennifer ||= User.find_by_email('jennifer_grey@example.com') ||
                  User.create!(name: 'Jennifer Grey',
                               email: 'jennifer_grey@example.com',
                               username: 'jennifergrey',
                               password: 'gh0stmovie',
                               angular_ui_enabled: true)
  end

  def max
    @max ||= User.find_by_email('max@example.com') ||
             User.create!(name: 'Max Von Sydow',
                          email: 'max@example.com',
                          password: 'gh0stmovie',
                          username: 'mingthemerciless',
                          angular_ui_enabled: true)
  end

  def emilio
    @emilio ||= User.find_by_email('emilio@loomio.org') ||
                User.create!(name: 'Emilio Estevez',
                            email: 'emilio@loomio.org',
                            password: 'gh0stmovie',
                            angular_ui_enabled: true)
  end

  def judd
    @judd ||= User.find_by_email('judd@example.com') ||
              User.create!(name: 'Judd Nelson',
                           email: 'judd@example.com',
                           password: 'gh0stmovie',
                           angular_ui_enabled: true)
  end

  def test_group
    unless @test_group
      @test_group = Group.create!(name: 'Dirty Dancing Shoes',
                                  group_privacy: 'closed',
                                  discussion_privacy_options: 'public_or_private')
      @test_group.add_admin!  patrick
      @test_group.add_member! jennifer
      @test_group.add_member! emilio
    end
    @test_group
  end

  def muted_test_group
    unless @muted_test_group
      @muted_test_group = Group.create!(name: 'Muted Point Blank',
                                        group_privacy: 'closed',
                                        discussion_privacy_options: 'public_or_private')
      @muted_test_group.add_admin! patrick
      Membership.find_by(group: @muted_test_group, user: patrick).set_volume! :mute
    end
    @muted_test_group
  end

  def another_test_group
    unless @another_test_group
      @another_test_group = Group.create!(name: 'Point Break',
                                          group_privacy: 'closed',
                                          discussion_privacy_options: 'public_or_private',
                                          description: 'An FBI agent goes undercover to catch a gang of bank robbers who may be surfers.')
      @another_test_group.add_admin! patrick
      @another_test_group.add_member! max
    end
    @another_test_group
  end

  def test_discussion
    unless @test_discussion
      @test_discussion = Discussion.create(title: 'What star sign are you?',
                                           private: false,
                                           group: test_group,
                                           author: jennifer)
      DiscussionService.create(discussion: @test_discussion, actor: @test_discussion.author)
    end
    @test_discussion
  end

  def public_test_discussion
    unless @another_test_discussion
      @another_test_discussion = Discussion.create!(title: "The name's Johnny Utah!",
                                                    private: false,
                                                    group: another_test_group,
                                                    author: patrick)
    end
    @another_test_discussion
  end

  def private_test_discussion
    unless @another_test_discussion
      @another_test_discussion = Discussion.create!(title: 'But are you crazy enough?',
                                                    private: true,
                                                    group: another_test_group,
                                                    author: patrick)
    end
    @another_test_discussion
  end

  def test_subgroup
    unless @test_subgroup
      @test_subgroup = Group.create!(name: 'Johnny Utah',
                                     parent: another_test_group,
                                     discussion_privacy_options: 'public_or_private',
                                     group_privacy: 'closed')
      @test_subgroup.add_admin! patrick
    end
    @test_subgroup
  end

  def another_test_subgroup
    unless @another_test_subgroup
      @another_test_subgroup = Group.create!(name: 'Bodhi',
                                             parent: another_test_group,
                                             group_privacy: 'closed',
                                             discussion_privacy_options: 'public_or_private')
      @another_test_subgroup.add_admin! patrick
    end
    @another_test_subgroup
  end

  def test_proposal
    unless @test_proposal
      @test_proposal = Motion.new(name: 'lets go hiking to the moon and never ever ever come back!',
                                closing_at: 3.days.from_now.beginning_of_hour,
                                discussion: test_discussion)
      MotionService.create(motion: @test_proposal, actor: jennifer)
    end
    @test_proposal
  end

  def public_test_proposal
    unless @public_test_proposal
      @public_test_proposal = Motion.new(name: 'Lets holiday on Earth instead',
                                         closing_at: 3.days.from_now.beginning_of_hour,
                                         discussion: public_test_discussion)
      MotionService.create(motion: @public_test_proposal, actor: patrick)
    end
    @public_test_proposal
  end

  def test_vote
    unless @test_vote
      @test_vote = Vote.new(position: 'yes', motion: test_proposal, statement: 'I agree!')
      VoteService.create(vote: @test_vote, actor: patrick)
    end
    @test_vote
  end

  def another_test_vote
    unless @another_test_vote
      @another_test_vote = Vote.new(position: 'no', motion: test_proposal, statement: 'I disagree!')
      VoteService.create(vote: @another_test_vote, actor: jennifer)
    end
    @another_test_vote
  end

  def membership_request_from_logged_out
    membership_request = MembershipRequest.new(group: test_group,
                                               name: Faker::Name.name,
                                               email: Faker::Internet.email,
                                               introduction: Faker::Hacker.say_something_smart)
    MembershipRequestService.create(membership_request: membership_request)
    membership_request
  end

  def membership_request_from_user
    unless @membership_request_from_user
      @membership_request_from_user = MembershipRequest.new(group: test_group,
                                                            requestor: max,
                                                            introduction: "I'd like to make decisions with y'all")
      MembershipRequestService.create(membership_request: @membership_request_from_user)
    end
    @membership_request_from_user
  end

  def pending_invitation
    unless @pending_invitation
      @pending_invitation = InvitationService.invite_to_group(recipient_emails: ['judd@example.com'],
                                                              message: 'Come and join the group!',
                                                              group: test_group,
                                                              inviter: patrick).last
    end
    @pending_invitation
  end

  def test_empty_draft
    unless @test_empty_draft
      @test_empty_draft = Draft.create(draftable: test_group, user: patrick, payload: { discussion: { title: "", private: nil }})
    end
    @test_empty_draft
  end

  def setup_all_notifications_work
    #'comment_liked'
    comment = Comment.new(discussion: test_discussion, body: 'I\'m rather likeable')
    new_comment_event = CommentService.create(comment: comment, actor: patrick)
    comment_liked_event = CommentService.like(comment: comment, actor: jennifer)

    #'motion_closing_soon'
    motion_created_event = MotionService.create(motion: test_proposal,
                                                actor: jennifer)
    closing_soon_event = Events::MotionClosingSoon.publish!(test_proposal)

    #'motion_closed'
    second_motion_created_event = MotionService.create(motion: public_test_proposal,
                                                       actor: patrick)


    motion_closed_event = MotionService.close(public_test_proposal)

    #'motion_outcome_created'
    outcome_event = MotionService.create_outcome(motion: test_proposal,
                                                 params: {outcome: 'Were going hiking tomorrow'},
                                                 actor: jennifer)

    #'comment_replied_to'
    reply_comment = Comment.new(discussion: test_discussion,
                                body: 'I agree with you', parent: comment)
    CommentService.create(comment: reply_comment, actor: jennifer)

    #'user_mentioned'
    comment = Comment.new(discussion: test_discussion, body: 'hey @patrickswayze you look great in that tuxeido')
    CommentService.create(comment: comment, actor: jennifer)

    #'membership_requested',
    membership_request = MembershipRequest.new(name: 'The Ghost', email: 'boooooo@invisible.co', group: test_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: LoggedOutUser.new)

    #'membership_request_approved',
    another_group = Group.new(name: 'Stars of the 90\'s', group_privacy: 'closed')
    GroupService.create(group: another_group, actor: jennifer)
    membership_request = MembershipRequest.new(requestor: patrick, group: another_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: patrick)
    approval_event = MembershipRequestService.approve(membership_request: membership_request, actor: jennifer)

    #'user_added_to_group',
    #notify patrick that he has been added to jens group
    another_group = Group.new(name: 'Planets of the 80\'s')
    GroupService.create(group: another_group, actor: jennifer)
    MembershipService.add_users_to_group(users: [patrick], group: another_group, inviter: jennifer, message: 'join in')

    #'new_coordinator',
    #notify jennifer that patrick has made her a coordinator
    membership = Membership.find_by(user_id: patrick.id, group_id: another_group.id)
    new_coordinator_event = MembershipService.make_admin(membership: membership, actor: jennifer)
  end
end

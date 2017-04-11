module Dev::NintiesMoviesHelper
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
    @patrick.experienced!("introductionCarousel")
    @patrick
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
    @jennifer.experienced!("introductionCarousel")
    @jennifer
  end

  def max
    @max ||= User.find_by_email('max@example.com') ||
             User.create!(name: 'Max Von Sydow',
                          email: 'max@example.com',
                          password: 'gh0stmovie',
                          username: 'mingthemerciless',
                          angular_ui_enabled: true)
    @max.experienced!("introductionCarousel")
    @max
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

  def create_group
    unless @group
      @group = Group.create!(name: 'Dirty Dancing Shoes',
                                  group_privacy: 'closed',
                                  discussion_privacy_options: 'public_or_private')
      @group.add_admin!  patrick
      @group.add_member! jennifer
      @group.add_member! emilio
    end
    @group
  end

  def create_poll_group
    unless @poll_group
      @poll_group = Group.create!(name: 'Dirty Dancing Shoes',
                             group_privacy: 'closed',
                             discussion_privacy_options: 'public_or_private',
                             features: {use_polls: true})
      @poll_group.add_admin!  patrick
      @poll_group.add_member! jennifer
      @poll_group.add_member! emilio
    end
    @poll_group
  end

  def multiple_groups
    @groups = []
    10.times do
      group = Group.new(name: Faker::Name.name,
                        group_privacy: 'closed',
                        discussion_privacy_options: 'public_or_private')
      group.add_admin! patrick
      @groups << group
    end
    @groups
  end

  def muted_create_group
    unless @muted_group
      @muted_group = Group.create!(name: 'Muted Point Blank',
                                        group_privacy: 'closed',
                                        discussion_privacy_options: 'public_or_private')
      @muted_group.add_admin! patrick
      Membership.find_by(group: @muted_group, user: patrick).set_volume! :mute
    end
    @muted_group
  end

  def create_another_group
    unless @another_group
      @another_group = Group.create!(name: 'Point Break',
                                          group_privacy: 'closed',
                                          discussion_privacy_options: 'public_or_private',
                                          description: 'An FBI agent goes undercover to catch a gang of bank robbers who may be surfers.')
      @another_group.add_admin! patrick
      @another_group.add_member! max
    end
    @another_group
  end

  def create_discussion
    unless @discussion
      @discussion = Discussion.create(title: 'What star sign are you?',
                                           private: false,
                                           group: create_group,
                                           author: jennifer)
      DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    end
    @discussion
  end

  def create_public_discussion
    unless @another_discussion
      @another_discussion = Discussion.create!(title: "The name's Johnny Utah!",
                                                    private: false,
                                                    group: create_another_group,
                                                    author: patrick)
    end
    @another_discussion
  end

  def private_create_discussion
    unless @another_discussion
      @another_discussion = Discussion.create!(title: 'But are you crazy enough?',
                                                    private: true,
                                                    group: create_another_group,
                                                    author: patrick)
    end
    @another_discussion
  end

  def create_subgroup
    unless @subgroup
      @subgroup = Group.create!(name: 'Johnny Utah',
                                     parent: create_another_group,
                                     discussion_privacy_options: 'public_or_private',
                                     group_privacy: 'closed')
      @subgroup.add_admin! patrick
    end
    @subgroup
  end

  def another_create_subgroup
    unless @another_subgroup
      @another_subgroup = Group.create!(name: 'Bodhi',
                                             parent: create_another_group,
                                             group_privacy: 'closed',
                                             discussion_privacy_options: 'public_or_private',
                                             is_visible_to_parent_members: true)
      @another_subgroup.discussions.create(title: "Vaya con dios", private: false, author: patrick)
      @another_subgroup.add_admin! patrick
    end
    @another_subgroup
  end

  def create_proposal
    unless @proposal
      @proposal = Motion.new(name: 'lets go hiking to the moon and never ever ever come back!',
                                closing_at: 3.days.from_now.beginning_of_hour,
                                discussion: create_discussion)
      MotionService.create(motion: @proposal, actor: jennifer)
    end
    @proposal
  end

  def create_public_proposal
    unless @public_proposal
      @public_proposal = Motion.new(name: 'Lets holiday on Earth instead',
                                         closing_at: 3.days.from_now.beginning_of_hour,
                                         discussion: create_public_discussion)
      MotionService.create(motion: @public_proposal, actor: patrick)
    end
    @public_proposal
  end

  def create_another_public_proposal
    unless @another_public_proposal
      @another_public_proposal = Motion.new(name: 'Lets holiday on Venus instead',
                                         closing_at: 3.days.from_now.beginning_of_hour,
                                         discussion: create_public_discussion)
      MotionService.create(motion: @another_public_proposal, actor: jennifer)
    end
    @another_public_proposal
  end

  def create_vote
    unless @public_vote
      @public_vote = Vote.new(statement: "Indeed!", position: "yes", motion: create_public_proposal)
      VoteService.create(vote: @public_vote, actor: patrick)
    end
    @public_vote
  end

  def create_another_vote
    unless @another_public_vote
      @another_public_vote = Vote.new(statement: "Nayy!", position: "no", motion: create_public_proposal)
      VoteService.create(vote: @another_public_vote, actor: max)
    end
    @another_public_vote
  end

  def membership_request_from_logged_out
    membership_request = MembershipRequest.new(group: create_group,
                                               name: Faker::Name.name,
                                               email: Faker::Internet.email,
                                               introduction: Faker::Hacker.say_something_smart)
    MembershipRequestService.create(membership_request: membership_request)
    membership_request
  end

  def membership_request_from_user
    unless @membership_request_from_user
      @membership_request_from_user = MembershipRequest.new(group: create_group,
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
                                                              group: create_group,
                                                              inviter: patrick).last
    end
    @pending_invitation
  end

  def create_empty_draft
    unless @empty_draft
      @empty_draft = Draft.create(draftable: create_group, user: patrick, payload: { discussion: { title: "", private: nil }})
    end
    @empty_draft
  end


  def create_all_notifications
    #'comment_liked'
    comment = Comment.new(discussion: create_discussion, body: 'I\'m rather likeable')
    new_comment_event = CommentService.create(comment: comment, actor: patrick)
    comment_liked_event = CommentService.like(comment: comment, actor: jennifer)
    create_another_group.add_member! jennifer

    #'motion_closing_soon'
    motion_created_event = MotionService.create(motion: create_another_public_proposal,
                                                actor: jennifer)
    closing_soon_event = Events::MotionClosingSoon.publish!(create_another_public_proposal)

    #'motion_closed'
    second_motion_created_event = MotionService.create(motion: create_public_proposal,
                                                       actor: patrick)


    motion_closed_event = MotionService.close(create_public_proposal)

    #'motion_outcome_created'
    outcome_event = MotionService.create_outcome(motion: create_another_public_proposal,
                                                 params: {outcome: 'Were going hiking tomorrow'},
                                                 actor: jennifer)

    #'comment_replied_to'
    reply_comment = Comment.new(discussion: create_discussion,
                                body: 'I agree with you', parent: comment)
    CommentService.create(comment: reply_comment, actor: jennifer)

    #'user_mentioned'
    comment = Comment.new(discussion: create_discussion, body: 'hey @patrickswayze you look great in that tuxeido')
    CommentService.create(comment: comment, actor: jennifer)

    #'membership_requested',
    membership_request = MembershipRequest.new(name: 'The Ghost', email: 'boooooo@invisible.co', group: create_group)
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
    #notify patrick that jennifer has made him a coordinator
    membership = Membership.find_by(user_id: patrick.id, group_id: another_group.id)
    new_coordinator_event = MembershipService.make_admin(membership: membership, actor: jennifer)

    #'invitation_accepted',
    #notify patrick that his invitation to emilio has been accepted
    invitation = InvitationService.invite_to_group(recipient_emails: [emilio.email], group: another_group, inviter: patrick)
    InvitationService.redeem(invitation.first, emilio)
  end
end

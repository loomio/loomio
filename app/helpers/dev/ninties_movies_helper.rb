module Dev::NintiesMoviesHelper
  include Dev::FakeDataHelper

  # try to just return objects here. Don't knit them together. Leave that for
  # the development controller action to do if possible
  def patrick
    @patrick ||= User.find_by(email: 'patrick_swayze@example.com') ||
                 User.create!(name: 'Patrick Swayze',
                              email: 'patrick_swayze@example.com',
                              is_admin: false,
                              username: 'patrickswayze',
                              password: 'gh0stmovie',
                              uploaded_avatar: File.new("#{Rails.root}/spec/fixtures/images/patrick.png"),
                              detected_locale: 'en',
                              email_verified: true)

    @patrick.update(avatar_kind: 'uploaded')
    @patrick.experienced!("vue_client") if params[:vue]
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
    @jennifer ||= User.find_by(email: 'jennifer_grey@example.com') ||
                  User.create!(name: 'Jennifer Grey',
                               email: 'jennifer_grey@example.com',
                               username: 'jennifergrey',
                               uploaded_avatar: File.new("#{Rails.root}/spec/fixtures/images/jennifer.png"),
                               email_verified: true)
    @jennifer.update(avatar_kind: 'uploaded')
    @jennifer.experienced!("vue_client") if params[:vue]
    @jennifer.experienced!("introductionCarousel")
    @jennifer
  end

  def max
    @max ||= User.find_by(email: 'max@example.com') ||
             User.create!(name: 'Max Von Sydow',
                          email: 'max@example.com',
                          password: 'gh0stmovie',
                          username: 'mingthemerciless',
                          email_verified: true)
    @max.experienced!("vue_client") if params[:vue]
    @max.experienced!("introductionCarousel")
    @max
  end

  def emilio
    @emilio ||= User.find_by(email: 'emilio@loomio.org') ||
                User.create!(name: 'Emilio Estevez',
                            email: 'emilio@loomio.org',
                            password: 'gh0stmovie',
                            email_verified: true)
  end

  def judd
    @judd ||= User.find_by(email: 'judd@example.com') ||
              User.create!(name: 'Judd Nelson',
                           email: 'judd@example.com',
                           password: 'gh0stmovie',
                           email_verified: true)
  end

  def rudd
    @rudd ||= User.find_by(email: 'rudd@example.com') ||
              User.create!(name: 'Paul Rudd',
                           email: 'rudd@example.com',
                           password: 'gh0stmovie',
                           email_verified: true)
  end

  def create_group
    unless @group
      @group = FormalGroup.create!(name: 'Dirty Dancing Shoes',
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
      @poll_group = FormalGroup.create!(name: 'Dirty Dancing Shoes',
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
      group = FormalGroup.new(name: Faker::Name.name,
                        group_privacy: 'closed',
                        discussion_privacy_options: 'public_or_private')
      group.add_admin! patrick
      @groups << group
    end
    @groups
  end

  def muted_create_group
    unless @muted_group
      @muted_group = FormalGroup.create!(name: 'Muted Point Blank',
                                        group_privacy: 'closed',
                                        discussion_privacy_options: 'public_or_private')
      @muted_group.add_admin! patrick
      Membership.find_by(group: @muted_group, user: patrick).set_volume! :mute
    end
    @muted_group
  end

  def create_another_group
    unless @another_group
      @another_group = FormalGroup.create!(name: 'Point Break',
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

  def create_closed_discussion
    unless @closed_discussion
      @closed_discussion = Discussion.create(title: 'This thread is old and closed',
                                             private: false,
                                             closed_at: Time.now,
                                             group: create_group,
                                             author: jennifer)
      DiscussionService.create(discussion: @closed_discussion, actor: @closed_discussion.author)
    end
    @closed_discussion
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
      @subgroup = FormalGroup.create!(name: 'Johnny Utah',
                                     parent: create_another_group,
                                     discussion_privacy_options: 'public_or_private',
                                     group_privacy: 'closed')
      @subgroup.add_admin! patrick
    end
    @subgroup
  end

  def another_create_subgroup
    unless @another_subgroup
      @another_subgroup = FormalGroup.create!(name: 'Bodhi',
                                             parent: create_another_group,
                                             group_privacy: 'closed',
                                             discussion_privacy_options: 'public_or_private',
                                             is_visible_to_parent_members: true)
      @another_subgroup.discussions.create(title: "Vaya con dios", private: false, author: patrick)
      @another_subgroup.add_admin! patrick
    end
    @another_subgroup
  end

  def pending_invitation
    @pending_membership ||= Membership.create(user: User.new(email: 'judd@example.com'),
                                              group: create_group, inviter: patrick)
  end

  def create_empty_draft
    unless @empty_draft
      @empty_draft = Draft.create(draftable: create_group, user: patrick, payload: { discussion: { title: "", private: nil }})
    end
    @empty_draft
  end

  def create_comment
    unless @create_comment
      @create_comment ||= Comment.create!(
        discussion: create_discussion,
        author: patrick,
        body: 'Hello world!'
      )
    end
    @create_comment
  end

  def create_poll
    @create_poll ||= Poll.create!(
      discussion: create_discussion,
      poll_type: :proposal,
      poll_option_names: %w(agree abstain disagree block),
      author: patrick,
      title: "Let's go to the moon!"
    )
  end

  def create_stance
    @create_stance ||= Stance.create(
      poll: create_poll,
      participant: patrick,
      choice: :agree,
      reason: "I have unreasonably high expectations for how this will go!"
    )
  end

  def create_outcome
    @create_outcome ||= Outcome.create!(
      poll: create_poll.tap { |p| p.update(closed_at: 1.day.ago) },
      author: patrick,
      statement: "Okay let's do it!"
    )
  end

  def create_all_activity_items
    # discussion_edited
    create_discussion
    create_discussion.update(title: "another discussion title")
    Events::DiscussionEdited.publish!(create_discussion, patrick)

    # discussion_moved
    Events::DiscussionMoved.publish!(create_discussion, patrick, create_another_group)

    # new_comment
    Events::NewComment.publish!(create_comment)

    # poll_created
    Events::PollCreated.publish!(create_poll, patrick)

    # poll_edited
    create_poll.update(title: "Another poll title")
    Events::PollEdited.publish!(create_poll, patrick)

    # stance_created
    Events::StanceCreated.publish!(create_stance)

    # poll_expired
    Events::PollExpired.publish!(create_poll)

    # poll_closed_by_user
    Events::PollClosedByUser.publish!(create_poll, patrick)

    # outcome_created
    Events::OutcomeCreated.publish!(create_outcome)
  end


  def create_all_notifications
    #'reaction_created'
    comment = Comment.new(discussion: create_discussion, body: 'I\'m rather likeable')
    reaction = Reaction.new(reactable: comment, reaction: ":heart:")
    new_comment_event = CommentService.create(comment: comment, actor: patrick)
    reaction_created_event = ReactionService.update(reaction: reaction, params: {reaction: ':slight_smile:'}, actor: jennifer)
    create_another_group.add_member! jennifer

    #'comment_replied_to'
    reply_comment = Comment.new(discussion: create_discussion,
                                body: 'I agree with you', parent: comment)
    CommentService.create(comment: reply_comment, actor: jennifer)

    #'user_mentioned'
    comment = Comment.new(discussion: create_discussion, body: 'hey @patrickswayze you look great in that tuxeido')
    CommentService.create(comment: comment, actor: jennifer)

    [max, emilio, judd].each {|u| comment.group.add_member! u}
    ReactionService.update(reaction: Reaction.new(reactable: comment), params: {reaction: ':slight_smile:'}, actor: jennifer)
    ReactionService.update(reaction: Reaction.new(reactable: comment), params: {reaction: ':heart:'}, actor: patrick)
    ReactionService.update(reaction: Reaction.new(reactable: comment), params: {reaction: ':laughing:'}, actor: max)
    ReactionService.update(reaction: Reaction.new(reactable: comment), params: {reaction: ':cry:'}, actor: emilio)
    ReactionService.update(reaction: Reaction.new(reactable: comment), params: {reaction: ':wave:'}, actor: judd)

    #'membership_requested',
    membership_request = MembershipRequest.new(group: create_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: rudd)

    #'membership_request_approved',
    another_group = FormalGroup.new(name: 'Stars of the 90\'s', group_privacy: 'closed')
    GroupService.create(group: another_group, actor: jennifer)
    membership_request = MembershipRequest.new(requestor: patrick, group: another_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: patrick)
    approval_event = MembershipRequestService.approve(membership_request: membership_request, actor: jennifer)

    #'user_added_to_group',
    #notify patrick that he has been added to jens group
    another_group = FormalGroup.new(name: 'Planets of the 80\'s')
    GroupService.create(group: another_group, actor: jennifer)
    jennifer.reload
    MembershipService.add_users_to_group(users: [patrick], group: another_group, inviter: jennifer)

    #'new_coordinator',
    #notify patrick that jennifer has made him a coordinator
    membership = Membership.find_by(user_id: patrick.id, group_id: another_group.id)
    new_coordinator_event = MembershipService.make_admin(membership: membership, actor: jennifer)

    #'invitation_accepted',
    #notify patrick that his invitation to emilio has been accepted
    membership = Membership.create(user: emilio, group: another_group, inviter: patrick)
    MembershipService.redeem(membership: membership, actor: emilio)

    'poll_created'
    poll = FactoryBot.create(:poll, discussion: create_discussion, group: create_group, author: jennifer, closing_at: 24.hours.from_now)
    AnnouncementService.create(
      model: poll,
      params: { kind: :poll_created, recipients: { user_ids: patrick.id }},
      actor: jennifer
    )

    #'poll_closing_soon'
    PollService.publish_closing_soon

    #'outcome_created'
    poll = FactoryBot.build(:poll, discussion: create_discussion, author: jennifer, closed_at: 1.day.ago)

    PollService.create(poll: poll, actor: jennifer)
    outcome = FactoryBot.build(:outcome, poll: poll)
    AnnouncementService.create(
      model: outcome,
      params: { kind: :outcome_created, recipients: { user_ids: patrick.id } },
      actor: jennifer
    )

    #'stance_created'
    # notify patrick that someone has voted on his proposal
    poll = FactoryBot.build(:poll, discussion: create_discussion, notify_on_participate: true, voter_can_add_options: true)
    PollService.create(poll: poll, actor: patrick)
    jennifer_stance = FactoryBot.build(:stance, poll: poll, choice: "agree")
    StanceService.create(stance: jennifer_stance, actor: jennifer)

    # create poll_option_added event (notifying author)
    option_added_event = PollService.add_options(poll: poll, params: {poll_option_names: "wark"}, actor: jennifer)
  end
end

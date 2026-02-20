module Dev::NintiesMoviesHelper
  include Dev::FakeDataHelper

  private

  # try to just return objects here. Don't knit them together. Leave that for
  # the development controller action to do if possible
  def patrick
    @patrick ||= User.find_by(email: 'patrick@example.com') ||
                 User.create!(name: 'Patrick Swayze',
                              email: 'patrick@example.com',
                              is_admin: false,
                              username: 'patrickswayze',
                              password: 'gh0stmovie',
                              experiences: {changePicture: true, hideOnboarding: true},
                              detected_locale: 'en',
                              date_time_pref: 'day_abbr',
                              avatar_kind: 'uploaded',
                              email_verified: true)
    @patrick.uploaded_avatar.attach io: File.new(Rails.root.join("spec/fixtures/images/patrick.png")), filename: 'patrick.png'
    @patrick.update(avatar_kind: :uploaded)
    @patrick
  end

  def patricks_contact
    if patrick.contacts.empty?
      patrick.contacts.create(name: 'Keanu Reeves',
                              email: 'keanu@example.com',
                              date_time_pref: 'day_abbr',
                              source: 'gmail')
    end
  end

  def jennifer
    @jennifer ||= User.find_by(email: 'jennifer@example.com') ||
                  User.create!(name: 'Jennifer Grey',
                               email: 'jennifer@example.com',
                               date_time_pref: 'day_abbr',
                               username: 'jennifergrey',
                               experiences: {changePicture: true},
                               email_verified: true)
    @jennifer.uploaded_avatar.attach io: File.new("#{Rails.root}/spec/fixtures/images/jennifer.png"), filename: 'jen.jpg'
    @jennifer.update(avatar_kind: :uploaded)

    @jennifer
  end

  def max
    @max ||= User.find_by(email: 'max@example.com') ||
             User.create!(name: 'Max Von Sydow',
                          email: 'max@example.com',
                          password: 'gh0stmovie',
                          username: 'mingthemerciless',
                          date_time_pref: 'day_abbr',
                          email_verified: true)
    @max
  end

  def emilio
    @emilio ||= User.find_by(email: 'emilio@example.com') ||
                User.create!(name: 'Emilio Estevez',
                            email: 'emilio@example.com',
                            password: 'gh0stmovie',
                            date_time_pref: 'day_abbr',
                            email_verified: true)
  end

  def judd
    @judd ||= User.find_by(email: 'judd@example.com') ||
              User.create!(name: 'Judd Nelson',
                           email: 'judd@example.com',
                           password: 'gh0stmovie',
                           date_time_pref: 'day_abbr',
                           email_verified: true)
  end

  def rudd
    @rudd ||= User.find_by(email: 'rudd@example.com') ||
              User.create!(name: 'Paul Rudd',
                           email: 'rudd@example.com',
                           password: 'gh0stmovie',
                           date_time_pref: 'day_abbr',
                           email_verified: true)
  end

  def create_group
    unless @group
      @group = Group.new(name: 'Dirty Dancing Shoes',
                        description: 'The best place for dancing shoes. _every_ shoe is **dirty**!',
                        group_privacy: 'closed',
                        handle: 'shoes',
                        discussion_privacy_options: 'public_or_private', creator: patrick)
      file = open(Rails.root.join('public','brand','icon_sky_150h.png'))
      @group.logo.attach(io: file, filename: 'logo.png')
      GroupService.create(group: @group, actor: @group.creator)
      @group.add_admin!  patrick
      @group.add_member! jennifer
      @group.add_member! emilio
    end
    @group
  end

  def create_poll_group
    unless @poll_group
      @poll_group = Group.new(name: 'Dirty Dancing Shoes',
                             group_privacy: 'closed',
                             discussion_privacy_options: 'public_or_private',
                             creator: patrick)
      GroupService.create(group: @poll_group, actor: @poll_group.creator)
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
                        discussion_privacy_options: 'public_or_private', creator: patrick)
      group.add_admin! patrick
      GroupService.create(group: group, actor: group.creator)
      @groups << group
    end
    @groups
  end

  def muted_create_group
    unless @muted_group
      @muted_group = Group.new(name: 'Muted Point Blank',
                                        group_privacy: 'closed',
                                        discussion_privacy_options: 'public_or_private', creator: patrick)
      GroupService.create(group: @muted_group, actor: @muted_group.creator)
      @muted_group.add_admin! patrick
      Membership.find_by(group: @muted_group, user: patrick).set_volume! :mute
    end
    @muted_group
  end

  def create_another_group
    unless @another_group
      @another_group = Group.new(name: 'Point Break',
                                          group_privacy: 'closed',
                                          discussion_privacy_options: 'public_or_private',
                                          description: 'An FBI agent goes undercover to catch a gang of bank robbers who may be surfers.', creator: patrick)
      GroupService.create(group: @another_group, actor: @another_group.creator)
      @another_group.add_admin! patrick
      @another_group.add_member! max
    end
    @another_group
  end

  def create_discussion
    unless @discussion
      result = DiscussionService.create(params: {group_id: create_group.id, title: 'What star sign are you?', private: false, link_previews: [{'title': 'link title', 'url': 'https://www.example.com', 'description': 'a link to a page', 'image': 'https://www.loomio.org/theme/logo.svg', 'hostname':'www.example.com'}]}, actor: jennifer)
      @discussion = result[:discussion]
    end
    @discussion
  end

  def create_another_discussion
    unless @another_discussion
      result = DiscussionService.create(params: {group_id: create_group.id, title: 'Waking Up in Reno', private: false}, actor: jennifer)
      @another_discussion = result[:discussion]
    end
    @another_discussion
  end

  def create_closed_discussion
    unless @closed_discussion
      result = DiscussionService.create(params: {group_id: create_group.id, title: 'This thread is old and closed', private: false, closed_at: Time.now}, actor: jennifer)
      @closed_discussion = result[:discussion]
    end
    @closed_discussion
  end

  def create_public_discussion
    unless @another_discussion
      result = DiscussionService.create(params: {group_id: create_another_group.id, title: "The name's Johnny Utah!", private: false}, actor: patrick)
      @another_discussion = result[:discussion]
    end
    @another_discussion
  end

  def private_create_discussion
    unless @another_discussion
      result = DiscussionService.create(params: {group_id: create_another_group.id, title: 'But are you crazy enough?', private: true}, actor: patrick)
      @another_discussion = result[:discussion]
    end
    @another_discussion
  end

  def create_subgroup
    unless @subgroup
      @subgroup = Group.new(name: 'Johnny Utah',
                                     parent: create_another_group,
                                     discussion_privacy_options: 'public_or_private',
                                     group_privacy: 'closed', creator: patrick)
      GroupService.create(group: @subgroup, actor: @subgroup.creator)
      DiscussionService.create(params: {group_id: @subgroup.id, title: "Vaya con dios", private: false}, actor: patrick)
      @subgroup.add_admin! patrick
    end
    @subgroup
  end

  def another_create_subgroup
    unless @another_subgroup
      @another_subgroup = Group.new(name: 'Bodhi',
                                             parent: create_another_group,
                                             group_privacy: 'closed',
                                             discussion_privacy_options: 'public_or_private',
                                             is_visible_to_parent_members: true, creator: patrick)
      GroupService.create(group: @another_subgroup, actor: @another_subgroup.creator)
      DiscussionService.create(params: {group_id: @another_subgroup.id, title: "Vaya con dios 2", private: false}, actor: patrick)
      @another_subgroup.add_admin! patrick
    end
    @another_subgroup
  end

  def pending_invitation
    @pending_membership ||= Membership.create(user: User.new(email: 'judd@example.com'),
                                              group: create_group, inviter: patrick)
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
      title: "Let's go to the moon!",
      closing_at: 10.days.from_now
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
    Events::DiscussionEdited.publish!(discussion: create_discussion, actor: create_discussion.author)

    # discussion_moved
    Events::DiscussionMoved.publish!(create_discussion, patrick, create_another_group)

    # new_comment
    Events::NewComment.publish!(create_comment)

    # poll_created
    Events::PollCreated.publish!(create_poll, patrick)

    # poll_edited
    create_poll.update(title: "Another poll title")
    Events::PollEdited.publish!(poll: create_poll, actor: patrick)

    # stance_created
    Events::StanceCreated.publish!(create_stance)

    # poll_expired
    Events::PollExpired.publish!(create_poll)

    # poll_closed_by_user
    Events::PollClosedByUser.publish!(create_poll, patrick)

    # outcome_created
    Events::OutcomeCreated.publish!(outcome: create_outcome)
  end


  def create_all_notifications
    #'reaction_created'
    patrick_comment = Comment.new(parent: create_discussion, body: 'I\'m rather likeable')
    reaction = Reaction.new(reactable: patrick_comment, reaction: ":heart:")
    new_comment_event = CommentService.create(comment: patrick_comment, actor: patrick)
    reaction_created_event = ReactionService.update(reaction: reaction, params: {reaction: ':slight_smile:'}, actor: jennifer)
    create_another_group.add_member! jennifer

    #'comment_replied_to'
    jennifer_comment = Comment.new(parent: patrick_comment,
                          body: 'hey @patrickswayze you look great in that tuxeido (jen reply to patrick)')
    CommentService.create(comment: jennifer_comment, actor: jennifer)

    #'user_mentioned'
    reply_comment = Comment.new(body: 'I agree with @patrickswayze (jen mention patrick)', parent: jennifer_comment)
    CommentService.create(comment: reply_comment, actor: jennifer)


    [max, emilio, judd].each {|u| patrick_comment.group.add_member! u}
    ReactionService.update(reaction: Reaction.new(reactable: patrick_comment), params: {reaction: ':slight_smile:'}, actor: jennifer)
    ReactionService.update(reaction: Reaction.new(reactable: patrick_comment), params: {reaction: ':heart:'}, actor: patrick)
    ReactionService.update(reaction: Reaction.new(reactable: patrick_comment), params: {reaction: ':laughing:'}, actor: max)
    ReactionService.update(reaction: Reaction.new(reactable: patrick_comment), params: {reaction: ':cry:'}, actor: emilio)
    ReactionService.update(reaction: Reaction.new(reactable: patrick_comment), params: {reaction: ':wave:'}, actor: judd)

    #'membership_requested',
    membership_request = MembershipRequest.new(group: create_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: rudd)

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
    jennifer.reload
    GroupService.invite(group: another_group, params: { recipient_user_ids: [patrick.id] }, actor: jennifer)

    #'new_coordinator',
    #notify patrick that jennifer has made him a coordinator
    membership = Membership.find_by(user_id: patrick.id, group_id: another_group.id)
    new_coordinator_event = MembershipService.make_admin(membership: membership, actor: jennifer)

    #'invitation_accepted',
    #notify patrick that his invitation to emilio has been accepted
    membership = Membership.create(user: emilio, group: another_group, inviter: patrick)
    MembershipService.redeem(membership: membership, actor: emilio)

    poll = Poll.new(poll_type: :poll, title: "Invitation poll", poll_option_names: %w[agree abstain disagree block], discussion: create_discussion, group: create_group, author: jennifer, closing_at: 24.hours.from_now, notify_on_closing_soon: 'voters', specified_voters_only: true)
    PollService.create(poll: poll, actor: jennifer)
    PollService.invite(
      poll: poll,
      params: { recipient_user_ids: [patrick.id], notify_recipients: true },
      actor: jennifer
    )

    #'poll_closing_soon'
    PollService.publish_closing_soon

    #'outcome_created'
    poll = Poll.new(poll_type: :proposal, title: "Outcome poll", poll_option_names: %w[agree abstain disagree block], discussion: create_discussion, author: jennifer, closed_at: 1.day.ago, closing_at: 1.day.ago)

    PollService.create(poll: poll, actor: jennifer)
    outcome = Outcome.new(poll: poll, author: jennifer, statement: "Let's do it!")
    OutcomeService.create(
      outcome: outcome,
      params: {recipient_user_ids: [patrick.id]},
      actor: jennifer
    )

    #'stance_created'
    # notify patrick that someone has voted on his proposal
    poll = Poll.new(poll_type: :proposal, title: "Stance poll", poll_option_names: %w[agree abstain disagree block], closing_at: 4.days.from_now, discussion: create_discussion, voter_can_add_options: true)
    PollService.create(poll: poll, actor: patrick)
  end
end

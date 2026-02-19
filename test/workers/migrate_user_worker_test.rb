require 'test_helper'

class MigrateUserWorkerTest < ActiveSupport::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @patrick = User.create!(name: "Patrick#{hex}", email: "patrick#{hex}@example.com", username: "patrickswayze#{hex}", email_verified: true)
    @jennifer = User.create!(name: "Jennifer#{hex}", email: "jennifer#{hex}@example.com", username: "jennifergrey#{hex}", email_verified: true)

    @group = Group.new(name: "DirtyDancing#{hex}", group_privacy: 'secret', handle: "dirtydancing#{hex}")
    @group.creator = @patrick
    @group.save!

    @another_group = Group.new(name: "AnotherGroup#{hex}", group_privacy: 'secret', handle: "anothergroup#{hex}")
    @another_group.creator = @patrick
    @another_group.save!

    @group.add_admin!(@patrick)
    @group.add_admin!(@jennifer)
    @another_group.add_admin!(@patrick)

    @jennifer_membership = @group.memberships.find_by(user: @jennifer)
    @jennifer_membership.update!(accepted_at: 2.days.ago)

    @discussion = Discussion.new(title: "MigrateTest#{hex}", group: @group, author: @patrick)
    DiscussionService.create(discussion: @discussion, actor: @patrick)
    DiscussionService.update(discussion: @discussion, params: {title: "new version #{hex}"}, actor: @patrick)

    version = @discussion.versions.last
    version.update!(whodunnit: @patrick.id) if version

    TopicReader.for(user: @patrick, topic: @discussion.topic)
    TopicReader.for(user: @jennifer, topic: @discussion.topic)

    @patrick_comment = Comment.new(parent: @discussion, body: "Patrick's comment #{hex}")
    CommentService.create(comment: @patrick_comment, actor: @patrick)

    @jennifer_comment = Comment.new(parent: @discussion, body: "Jennifer's comment #{hex}")
    CommentService.create(comment: @jennifer_comment, actor: @jennifer)

    @reaction = Reaction.create!(reactable: @patrick_comment, user: @patrick, reaction: "+1")

    @poll = Poll.new(
      title: "MigratePoll#{hex}",
      poll_type: 'proposal',
      group: @group,
      discussion: @discussion,
      author: @patrick,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    )
    PollService.create(poll: @poll, actor: @patrick)

    jennifer_stance = Stance.find_by(poll: @poll, participant: @jennifer, latest: true)
    jennifer_stance.choice = @poll.poll_option_names.first
    StanceService.create(stance: jennifer_stance, actor: @jennifer)

    @poll.update!(closed_at: 1.day.ago)
    @outcome = Outcome.new(poll: @poll, statement: "We decided", author: @patrick)
    OutcomeService.create(outcome: @outcome, actor: @patrick)

    @pending_user = User.create!(email: "pending#{hex}@example.com", email_verified: false)
    @pending_membership = Membership.create!(group: @group, user: @pending_user, inviter: @patrick, accepted_at: nil)

    # MembershipRequest requires requestor NOT be a member of the group
    mr_owner = User.create!(name: "MROwner#{hex}", email: "mrowner#{hex}@example.com", username: "mrowner#{hex}", email_verified: true)
    @mr_group = Group.new(name: "MRGroup#{hex}", group_privacy: 'secret', handle: "mrgroup#{hex}")
    @mr_group.creator = mr_owner
    @mr_group.save!
    @mr_group.add_admin!(mr_owner)
    @membership_request = MembershipRequest.create!(requestor: @patrick, group: @mr_group)

    @identity = Identity.create!(user: @patrick, uid: "saml_#{hex}", access_token: SecureRandom.uuid, identity_type: :saml)

    [@patrick, @jennifer].each { |u| u.update_attribute(:sign_in_count, 1) }

    ActionMailer::Base.deliveries.clear
  end

  test "updates user_id references from old to new" do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      MigrateUserWorker.perform_async(@patrick.id, @jennifer.id)
    end

    @patrick.reload
    @jennifer.reload

    j_stance = Stance.find_by(poll: @poll, participant: @jennifer, latest: true)

    assert_equal @jennifer, @patrick_comment.reload.author
    assert_equal @jennifer, @pending_membership.reload.inviter
    assert_equal @jennifer, @group.reload.creator
    assert_equal @jennifer, @jennifer_membership.reload.user
    assert_equal @jennifer, @reaction.reload.author
    assert_equal @jennifer, @poll.reload.author
    assert_equal @jennifer, @outcome.reload.author
    assert_equal @jennifer, j_stance.reload.author
    assert_equal true, j_stance.reload.latest
    assert_equal @jennifer, @membership_request.reload.requestor
    assert_equal @jennifer, @identity.reload.user
    assert TopicReader.find_by(topic: @discussion.topic, user: @jennifer).present?
    assert @another_group.members.exists?(@jennifer.id)
    assert_equal 2, @jennifer.memberships_count

    assert_equal 1, @poll.reload.voters_count
    assert_equal 2, @group.reload.memberships_count
    assert_equal 1, @group.reload.pending_memberships_count
    assert_equal 1, @group.reload.admin_memberships_count

    version = @discussion.versions.last
    assert_equal @jennifer.id, version.whodunnit if version

    assert @patrick.reload.deactivated_at.present?
    assert_equal 2, @jennifer.reload.sign_in_count
  end
end

require "test_helper"

# Real commits exercise publication ordering as well as transactional counts.
class RecordCountsCommitTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @group = Group.create!(name: "Counter cache group", group_privacy: "secret")
    @user = users(:alien)
    @user.update_memberships_count
  end

  test "membership commit updates counts without saving unrelated group or user changes" do
    group_name = @group.name
    user_name = @user.name
    group_updated_at = @group.updated_at
    user_updated_at = @user.updated_at
    user_memberships_count = @user.memberships_count
    @group.name = "Unsaved group name"
    @user.name = "Unsaved user name"

    Membership.transaction do
      Membership.create!(group: @group, user: @user, admin: true, delegate: true)
      assert_equal 1, Group.find(@group.id).memberships_count
      assert_equal user_memberships_count + 1, User.find(@user.id).memberships_count
    end

    persisted_group = Group.find(@group.id)
    persisted_user = User.find(@user.id)
    assert_equal [1, 1, 1], persisted_group.attributes.values_at(
      "memberships_count", "pending_memberships_count", "admin_memberships_count"
    )
    assert_equal user_memberships_count + 1, persisted_user.memberships_count
    assert_equal group_name, persisted_group.name
    assert_equal user_name, persisted_user.name
    assert_equal group_updated_at, persisted_group.updated_at
    assert_equal user_updated_at, persisted_user.updated_at
    assert @group.name_changed?
    assert @user.name_changed?
  end

  test "membership rollback leaves counts and access unchanged" do
    user_memberships_count = @user.memberships_count

    Membership.transaction do
      Membership.create!(group: @group, user: @user, admin: true)
      raise ActiveRecord::Rollback
    end

    assert_equal 0, @group.reload.memberships_count
    assert_equal 0, @group.admin_memberships_count
    assert_equal user_memberships_count, @user.reload.memberships_count
    assert_not @group.admins.exists?(@user.id)
    assert_not @user.can?(:update, @group)
  end

  test "moving a membership updates both groups and both users" do
    destination = Group.create!(name: "Counter destination", group_privacy: "secret")
    user_destination = users(:user)
    user_destination.update_memberships_count
    user_source_count = @user.memberships_count
    user_destination_count = user_destination.memberships_count
    membership = Membership.create!(group: @group, user: @user, admin: true)

    Membership.transaction do
      membership.update!(group: destination, user: user_destination)
    end

    assert_equal 0, @group.reload.memberships_count
    assert_equal 0, @group.admin_memberships_count
    assert_equal 1, destination.reload.memberships_count
    assert_equal 1, destination.admin_memberships_count
    assert_equal user_source_count, @user.reload.memberships_count
    assert_equal user_destination_count + 1, user_destination.reload.memberships_count

    membership.destroy!
    assert_equal 0, destination.reload.memberships_count
    assert_equal 0, destination.admin_memberships_count
    assert_equal user_destination_count, user_destination.reload.memberships_count
  end

  test "a rolled back invitation savepoint does not suppress a later membership update" do
    Membership.transaction do
      Membership.transaction(requires_new: true) do
        Membership.create!(group: @group, user: @user, admin: true)
        raise ActiveRecord::Rollback
      end
      Membership.create!(group: @group, user: users(:user), accepted_at: Time.current)
    end

    assert_equal 1, @group.reload.memberships_count
    assert_equal 0, @group.admin_memberships_count
    assert_equal 0, @group.pending_memberships_count
    assert_equal [users(:user).id], @group.members.pluck(:id)
  end

  test "simultaneous membership commits keep group counts correct" do
    ready = Queue.new
    commit = Queue.new
    group_id = @group.id
    user_ids = users(:user, :member).map(&:id)
    writers = user_ids.map do |user_id|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          commit.pop
          Membership.create!(group_id: group_id, user_id: user_id, admin: true, accepted_at: Time.current)
        end
      end
    end

    Timeout.timeout(10) { writers.length.times { ready.pop } }
    writers.length.times { commit << true }
    writers.each(&:value)

    assert_equal 2, @group.reload.memberships_count
    assert_equal 2, @group.admin_memberships_count
    assert_equal 0, @group.pending_memberships_count
    assert_equal user_ids.sort, @group.members.pluck(:id).sort
  ensure
    writers&.length&.times { commit << true }
    writers&.each(&:join)
  end

  test "moving and deleting subgroups recounts the surviving parents" do
    destination = Group.create!(name: "Subgroup destination", group_privacy: "secret")
    subgroup = Group.create!(name: "Counted subgroup", parent: @group, group_privacy: "secret")
    assert_equal 1, @group.reload.subgroups_count

    Group.transaction { subgroup.update!(parent: destination) }
    assert_equal 0, @group.reload.subgroups_count
    assert_equal 1, destination.reload.subgroups_count

    subgroup.destroy!
    assert_equal 0, destination.reload.subgroups_count
  end

  test "template discard and restore update kept templates without saving the group" do
    template = PollTemplate.create!(group: @group, author: users(:admin), poll_type: "proposal", process_name: "Proposal",
                                   process_subtitle: "Template", default_duration_in_days: 3)
    assert_equal 1, @group.reload.poll_templates_count
    template.discard!
    assert_equal 0, @group.reload.poll_templates_count
    template.undiscard!
    assert_equal 1, @group.reload.poll_templates_count
    template.destroy!
    assert_equal 0, @group.reload.poll_templates_count
  end

  test "group and direct replies commit parent counts before the service publishes them" do
    [:discussion_topic, :direct_topic].each do |fixture|
      discussion = topics(fixture).topicable
      discussion.create_missing_created_topic_item! unless discussion.created_topic_item
      actor = discussion.author
      parent = CommentService.create(comment: Comment.new(parent: discussion, body: "Parent"), actor: actor)
      parent_item = parent.created_topic_item
      count_at_publication = nil

      CommentService.create(comment: Comment.new(parent: parent, body: "Reply"), actor: actor) do
        count_at_publication = parent_item.reload.child_count
      end

      assert_equal 1, count_at_publication, fixture
      assert_equal parent_item.children.count, parent_item.reload.child_count, fixture
    end
  end

  test "a failed reply transaction does not change parent counts or enqueue publication" do
    discussion = topics(:direct_topic).topicable
    discussion.create_missing_created_topic_item! unless discussion.created_topic_item
    actor = discussion.author
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: "Parent"), actor: actor)
    parent_item = parent.created_topic_item
    clear_enqueued_jobs

    assert_no_enqueued_jobs do
      Comment.transaction do
        CommentService.create(comment: Comment.new(parent: parent, body: "Rolled back reply"), actor: actor)
        raise ActiveRecord::Rollback
      end
    end

    assert_equal 0, parent_item.reload.child_count
    assert_empty parent_item.children
  end

  test "realtime reply publication sees committed parent counts even when the worker runs immediately" do
    discussion = topics(:direct_topic).topicable
    discussion.create_missing_created_topic_item! unless discussion.created_topic_item
    actor = discussion.author
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: "Parent"), actor: actor)
    parent_item = parent.created_topic_item
    counts_at_publication = []
    clear_enqueued_jobs

    MessageChannelService.stub(:publish_topic_models, ->(*, **) { counts_at_publication << parent_item.reload.child_count }) do
      perform_enqueued_jobs(only: PublishLiveUpdateTopicItemWorker) do
        CommentService.create(comment: Comment.new(parent: parent, body: "Published reply"), actor: actor)
      end
    end

    assert_equal [1], counts_at_publication
  end

  test "multiple replies in one transaction publish only after all parent counts are current" do
    discussion = topics(:discussion_topic).topicable
    discussion.create_missing_created_topic_item! unless discussion.created_topic_item
    actor = discussion.author
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: "Parent"), actor: actor)
    parent_item = parent.created_topic_item
    counts_at_publication = []
    clear_enqueued_jobs

    MessageChannelService.stub(:publish_topic_models, ->(*, **) { counts_at_publication << parent_item.reload.child_count }) do
      perform_enqueued_jobs(only: PublishLiveUpdateTopicItemWorker) do
        Comment.transaction do
          2.times do
            CommentService.create(comment: Comment.new(parent: parent, body: "Published reply"), actor: actor)
          end
          assert_empty enqueued_jobs
          assert_equal 2, parent_item.reload.child_count
        end
      end
    end

    assert_equal [2, 2], counts_at_publication
  end

  test "simultaneous replies keep parent counts and timeline positions consistent" do
    discussion = topics(:direct_topic).topicable
    discussion.create_missing_created_topic_item! unless discussion.created_topic_item
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: 'Parent'), actor: discussion.author)
    parent_id = parent.id
    actor_id = discussion.author_id
    ready = Queue.new
    start = Queue.new
    writers = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          start.pop
          CommentService.create(comment: Comment.new(parent: Comment.find(parent_id), body: 'Concurrent reply'),
                                actor: User.find(actor_id))
        end
      end
    end
    Timeout.timeout(10) { writers.length.times { ready.pop } }
    writers.length.times { start << true }
    writers.each(&:value)

    item = parent.created_topic_item
    assert_equal 2, item.child_count
    assert_equal [1, 2], item.children.order(:position).pluck(:position)
    TopicService.verify_integrity!(discussion.topic_id)
  ensure
    writers&.length&.times { start << true }
    writers&.each(&:join)
  end
end

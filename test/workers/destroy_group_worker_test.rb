require "test_helper"
require_relative "../support/access_volume_matrix"

class DestroyGroupWorkerTest < ActiveSupport::TestCase
  setup do
    @deletion_days_before = ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"]
    ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = "90"
  end

  teardown do
    ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = @deletion_days_before
  end

  test "deletes only the discard operation that scheduled the job" do
    group = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    group.discard!(at: 91.days.ago)
    discarded_at = group.discarded_at.iso8601(6)
    before = IntegrityAuditService.audit_orphan_records(include_ids: true)

    2.times { DestroyGroupWorker.perform_now(group.id, discarded_at) }

    assert_not Group.exists?(group.id)
    assert_not Group.exists?(subgroup.id)
    after = IntegrityAuditService.audit_orphan_records(include_ids: true)
    after.slice(:dangling_records, :missing_polymorphic_targets).each do |category, scopes|
      scopes.each do |name, ids|
        assert_empty(ids - before.fetch(category).fetch(name, []), name)
      end
    end
  end

  test "permanent deletion removes duplicate search documents and all revisions only within the group tree" do
    group = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    discussion = discussions(:discussion)
    topic = discussion.topic
    poll = PollService.create(params: { topic_id: topic.id, title: "Archived poll", poll_type: "proposal",
      closing_at: 2.days.from_now, poll_option_names: [ "Agree" ] }, actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant: users(:member_normal))
    weight_version = PaperTrail::Version.create!(item: stance, event: Stance::WEIGHT_EVENT)
    comment = Comment.create!(parent: discussion, user: users(:member_normal), body: "Archived reply")
    comment.create_missing_created_topic_item!
    reply = Comment.create!(parent: comment, user: users(:member_normal), body: "Archived nested reply")
    reply.create_missing_created_topic_item!
    child = Comment.create!(parent: poll, user: users(:member_normal), body: "Archived poll reply")
    child.create_missing_created_topic_item!
    topic.update_column(:group_id, subgroup.id)

    group.discard!(at: 91.days.ago)
    deleted_records = [ group, subgroup, topic, discussion, poll, stance, comment, reply, child ]
    kept_comment = comments(:public_discussion_comment)
    kept_version = kept_comment.versions.create!(event: "update")
    kept_document = kept_comment.pg_search_documents.create!(content: "Kept text")
    deleted_records.each { |record| record.versions.create!(event: "update") }
    [ discussion, poll ].each do |record|
      2.times { record.pg_search_documents.create!(content: "Archived text") }
    end

    DestroyGroupWorker.perform_now(group.id, group.discarded_at.iso8601(6))

    deleted_records.each { |record| assert_not PaperTrail::Version.exists?(item: record) }
    assert_not PaperTrail::Version.exists?(weight_version.id)
    [ discussion, poll ].each { |record| assert_not PgSearch::Document.exists?(searchable: record) }
    assert PaperTrail::Version.exists?(kept_version.id)
    assert PgSearch::Document.exists?(kept_document.id)

    kept_comment.destroy!
    assert PaperTrail::Version.exists?(kept_version.id)
  end

  test "an old job preserves a restored then rediscarded group" do
    group = groups(:orphan_group_tree)
    group.discard!(at: 91.days.ago)
    discarded_at = group.discarded_at.iso8601(6)
    group.undiscard!
    travel 1.minute do
      group.discard!(at: 91.days.ago)
      DestroyGroupWorker.perform_now(group.id, discarded_at)
    end

    assert Group.exists?(group.id)
    assert Group.exists?(groups(:orphan_subgroup).id)
  end

  test "legacy jobs without a discard timestamp cannot delete a group" do
    group = groups(:orphan_group)
    group.discard!(at: 91.days.ago)
    DestroyGroupWorker.perform_now(group.id)
    assert Group.exists?(group.id)
  end

  test "disabling cleanup preserves a group whose deletion was queued" do
    group = groups(:orphan_group_tree)
    group.discard!(at: 91.days.ago)
    discarded_at = group.discarded_at.iso8601(6)
    ENV.delete("LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS")

    DestroyGroupWorker.perform_now(group.id, discarded_at)

    assert Group.exists?(group.id)
    assert Group.exists?(groups(:orphan_subgroup).id)
  end

  test "increasing the deletion delay protects already queued groups" do
    group = groups(:orphan_group_tree)
    group.discard!(at: 91.days.ago)
    discarded_at = group.discarded_at.iso8601(6)

    ENV["LOOMIO_DELETE_DISCARDED_GROUPS_AFTER_X_DAYS"] = "120"
    DestroyGroupWorker.perform_now(group.id, discarded_at)

    assert Group.exists?(group.id)
    assert Group.exists?(groups(:orphan_subgroup).id)
  end

  test "a restored or recently discarded subgroup prevents deleting its tree" do
    group = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    group.discard!(at: 91.days.ago)
    [nil, 1.day.ago].each do |discarded_at|
      subgroup.update_column(:discarded_at, discarded_at)
      DestroyGroupWorker.perform_now(group.id, group.discarded_at.iso8601(6))
      assert Group.exists?(group.id)
      assert Group.exists?(subgroup.id)
    end
  end

  test "deletes a discarded subgroup under a kept parent only when subgroup deletion is enabled" do
    subgroups_before = ENV.delete("LOOMIO_DELETE_DISCARDED_SUBGROUPS_AFTER_X_DAYS")
    parent = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    subgroup.discard!(at: 31.days.ago)
    discarded_at = subgroup.discarded_at.iso8601(6)

    DestroyGroupWorker.perform_now(subgroup.id, discarded_at)
    assert Group.exists?(subgroup.id)

    ENV["LOOMIO_DELETE_DISCARDED_SUBGROUPS_AFTER_X_DAYS"] = "30"
    parent.update_column(:discarded_at, 1.day.ago)
    DestroyGroupWorker.perform_now(subgroup.id, discarded_at)
    assert Group.exists?(subgroup.id)

    parent.update_column(:discarded_at, nil)
    DestroyGroupWorker.perform_now(subgroup.id, discarded_at)
    assert Group.exists?(parent.id)
    assert_not Group.exists?(subgroup.id)
  ensure
    ENV["LOOMIO_DELETE_DISCARDED_SUBGROUPS_AFTER_X_DAYS"] = subgroups_before
  end

  test "deletion starts only when the full delay has elapsed" do
    travel_to Time.current.change(usec: 0) do
      group = groups(:orphan_group_tree)
      group.discard!(at: 90.days.ago + 1.second)
      discarded_at = group.discarded_at.iso8601(6)

      DestroyGroupWorker.perform_now(group.id, discarded_at)
      assert Group.exists?(group.id)

      travel 1.second
      DestroyGroupWorker.perform_now(group.id, discarded_at)
      assert_not Group.exists?(group.id)
    end
  end

  test "members and topic guests cannot schedule group deletion" do
    group = topics(:discussion_topic).group
    AccessVolumeMatrix::ROLES.excluding(:admin).each do |role|
      assert_no_enqueued_jobs(only: [ ActionMailer::MailDeliveryJob, DestroyGroupWorker ]) do
        assert_raises(CanCan::AccessDenied) { GroupService.warn_and_discard(group: group, actor: users(role)) }
      end
      assert_nil group.reload.discarded_at
    end
    assert_no_enqueued_jobs(only: [ ActionMailer::MailDeliveryJob, DestroyGroupWorker ]) do
      assert_raises(CanCan::AccessDenied) { GroupService.warn_and_discard(group: group, actor: LoggedOutUser.new) }
    end
    assert_nil group.reload.discarded_at
  end

  test "group coordinators warn and discard without enqueueing permanent deletion" do
    group = topics(:discussion_topic).group
    actor = users(:admin)
    assert_no_enqueued_jobs(only: DestroyGroupWorker) do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
        GroupService.warn_and_discard(group: group, actor: actor)
      end
    end
    assert_equal actor.id, group.reload.discarded_by
  end

  test "instance administrators can use the warning deletion path" do
    actor = users(:alien)
    actor.update!(is_admin: true)
    group = topics(:discussion_topic).group

    assert_no_enqueued_jobs(only: DestroyGroupWorker) do
      GroupService.warn_and_discard(group: group, actor: actor)
    end
    assert_equal actor.id, group.reload.discarded_by
  end

  test "instance administrators can discard without warning or permanent deletion" do
    actor = users(:admin)
    group = topics(:discussion_topic).group

    assert_no_enqueued_jobs(only: [ ActionMailer::MailDeliveryJob, DestroyGroupWorker ]) do
      GroupService.discard(group: group, actor: actor)
    end

    assert_equal actor.id, group.reload.discarded_by
  end

  test "unauthorized users cannot discard silently" do
    actor = users(:user)
    group = topics(:discussion_topic).group

    assert_raises(CanCan::AccessDenied) { GroupService.discard(group: group, actor: actor) }
    assert group.reload.kept?
  end

  test "repeated requests preserve the discard timestamp and do not warn again" do
    group = topics(:discussion_topic).group
    GroupService.warn_and_discard(group: group, actor: users(:admin))
    discarded_at = group.reload.discarded_at

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      GroupService.warn_and_discard(group: group, actor: users(:admin))
    end
    assert_equal discarded_at, group.reload.discarded_at
  end

  test "a rolled back discard does not warn or broadcast" do
    group = topics(:discussion_topic).group
    EventBus.stub(:broadcast, ->(*) { flunk "Rolled back discard was broadcast" }) do
      assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
        Group.transaction(requires_new: true) do
          GroupService.warn_and_discard(group: group, actor: users(:admin))
          raise ActiveRecord::Rollback
        end
      end
    end
    assert group.reload.kept?
  end
end

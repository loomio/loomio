require "test_helper"
require_relative "../support/access_volume_matrix"

class DestroyGroupWorkerTest < ActiveSupport::TestCase
  test "deletes only the discard operation that scheduled the job" do
    group = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    group.discard!
    discarded_at = group.discarded_at.iso8601(6)

    2.times { DestroyGroupWorker.perform_now(group.id, discarded_at) }

    assert_not Group.exists?(group.id)
    assert_not Group.exists?(subgroup.id)
  end

  test "an old job preserves a restored then rediscarded group" do
    group = groups(:orphan_group_tree)
    group.discard!
    discarded_at = group.discarded_at.iso8601(6)
    group.undiscard!
    travel 1.minute do
      group.discard!
      DestroyGroupWorker.perform_now(group.id, discarded_at)
    end

    assert Group.exists?(group.id)
    assert Group.exists?(groups(:orphan_subgroup).id)
  end

  test "legacy jobs without a discard timestamp cannot delete a group" do
    group = groups(:orphan_group)
    group.discard!
    DestroyGroupWorker.perform_now(group.id)
    assert Group.exists?(group.id)
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

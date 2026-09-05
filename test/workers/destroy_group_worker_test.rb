require "test_helper"

class DestroyGroupWorkerTest < ActiveSupport::TestCase
  test "deletes only the archive operation that scheduled the job" do
    group = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    group.archive!
    archived_at = group.archived_at.iso8601(6)

    2.times { DestroyGroupWorker.perform_now(group.id, archived_at) }

    assert_not Group.exists?(group.id)
    assert_not Group.exists?(subgroup.id)
  end

  test "an old job preserves a restored then rearchived group" do
    group = groups(:orphan_group_tree)
    group.archive!
    archived_at = group.archived_at.iso8601(6)
    group.unarchive!
    travel 1.minute do
      group.archive!
      DestroyGroupWorker.perform_now(group.id, archived_at)
    end

    assert Group.exists?(group.id)
    assert Group.exists?(groups(:orphan_subgroup).id)
  end

  test "legacy jobs without an archive timestamp cannot delete a group" do
    group = groups(:orphan_group)
    group.archive!
    DestroyGroupWorker.perform_now(group.id)
    assert Group.exists?(group.id)
  end

  test "immediate administrative deletion schedules the archive it actually performed" do
    group = groups(:orphan_group)
    assert_enqueued_with(job: DestroyGroupWorker, args: ->(args) { args == [ group.id, group.reload.archived_at.iso8601(6) ] }) do
      GroupService.destroy_without_warning!(group.id)
    end
  end

  test "members and topic guests cannot schedule group deletion" do
    group = topics(:discussion_topic).group
    %i[member_quiet member_loud alien_loud guest_admin_normal former_member_loud].each do |role|
      assert_no_enqueued_jobs(only: DestroyGroupWorker) do
        assert_raises(CanCan::AccessDenied) { GroupService.destroy(group: group, actor: users(role)) }
      end
      assert_nil group.reload.archived_at
    end
  end
end

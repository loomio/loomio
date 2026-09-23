require "test_helper"

class CleanupDiscardedGroupsTest < ActiveSupport::TestCase
  test "queues roots discarded beyond the grace period" do
    eligible = groups(:orphan_group_tree)
    eligible.discard!(at: 91.days.ago)
    recent = groups(:orphan_group)
    recent.discard!(at: 89.days.ago)

    assert_enqueued_with(job: DestroyGroupWorker, args: ->(args) { args == [ eligible.id, eligible.reload.discarded_at.iso8601(6) ] }) do
      CleanupService.destroy_discarded_groups
    end

    assert Group.exists?(eligible.id)
    assert Group.exists?(recent.id)
  end
end

require "test_helper"

class CleanupDiscardedGroupsTest < ActiveSupport::TestCase
  setup do
    @previous = ENV["LOOMIO_DISCARDED_GROUP_DELETION_ENABLED"]
    ENV["LOOMIO_DISCARDED_GROUP_DELETION_ENABLED"] = "1"
  end

  teardown do
    ENV["LOOMIO_DISCARDED_GROUP_DELETION_ENABLED"] = @previous
  end

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

  test "separate dispatches share a cap and avoid duplicate queued roots" do
    previous_adapter = DestroyGroupWorker.queue_adapter
    DestroyGroupWorker.queue_adapter = :solid_queue
    group = groups(:orphan_group_tree)
    other = groups(:orphan_group)
    group.discard!(at: 91.days.ago)
    other.discard!(at: 91.days.ago)
    pending = SolidQueue::Job.where(queue_name: "group_destruction", finished_at: nil)
    ActiveJob.perform_all_later(Array.new(CleanupService::DISCARDED_GROUP_DESTRUCTION_LIMIT - 1) { |index| DestroyGroupWorker.new(-index - 1) })

    assert_equal 1, CleanupService.destroy_discarded_groups(root_ids: [group.id])
    assert_equal 0, CleanupService.destroy_discarded_groups(root_ids: [other.id])
    assert_equal CleanupService::DISCARDED_GROUP_DESTRUCTION_LIMIT, pending.count

    pending.first.update!(finished_at: Time.current)
    assert_equal 0, CleanupService.destroy_discarded_groups(root_ids: [group.id])
    assert_equal 1, CleanupService.destroy_discarded_groups(root_ids: [other.id])
  ensure
    DestroyGroupWorker.queue_adapter = previous_adapter
  end
end

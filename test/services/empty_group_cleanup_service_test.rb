require "test_helper"

class EmptyGroupCleanupServiceTest < ActiveSupport::TestCase
  setup do
    @creator = users(:member_quiet)
  end

  test "applies the whole-tree cleanup eligibility matrix" do
    matrix = build_group_matrix
    candidate_ids = candidates.where(id: matrix.values.pluck(:root).map(&:id)).pluck(:id)

    matrix.each do |name, entry|
      assert_equal entry[:eligible], candidate_ids.include?(entry[:root].id), name
      assert_not_includes candidate_ids, entry[:subgroup].id, "#{name} subgroup must never be scheduled separately" if entry[:subgroup]
    end
  end

  test "archives the whole eligible tree and enqueues one root deletion" do
    root = create_group(name: "Scheduled root")
    subgroup = create_group(name: "Scheduled subgroup", parent: root)

    EmptyGroupCleanupService.stub(:candidate_groups, Group.where(id: root.id)) do
      assert_enqueued_with(job: DestroyGroupWorker, args: [ root.id ]) do
        assert_equal 1, EmptyGroupCleanupService.enqueue!
      end
    end

    assert root.reload.archived_at
    assert subgroup.reload.archived_at
  end

  private

  def candidates
    EmptyGroupCleanupService.candidate_groups
  end

  def create_group(name:, parent: nil)
    Group.create!(
      name: "#{name} #{SecureRandom.hex(4)}",
      creator: @creator,
      parent: parent,
      group_privacy: "secret",
      created_at: 2.years.ago
    )
  end

  def build_group_matrix
    {
      orphan_group: { root: groups(:orphan_group), eligible: true },
      active_free: { root: groups(:orphan_free_group), eligible: true },
      empty_tree: { root: groups(:orphan_group_tree), subgroup: groups(:orphan_subgroup), eligible: true },
      active_topic: { root: groups(:used_topic_group), eligible: false },
      discarded_topic: {
        root: groups(:used_discarded_topic_tree),
        subgroup: groups(:used_discarded_topic_subgroup),
        eligible: false
      },
      revoked_membership: {
        root: groups(:used_revoked_membership_tree),
        subgroup: groups(:used_revoked_membership_subgroup),
        eligible: false
      },
      multiple_users: { root: groups(:used_multiple_members_group), eligible: false },
      active_trial: { root: groups(:used_trial_group), eligible: false },
      active_paid: { root: groups(:used_paid_group), eligible: false },
      canceled_free: { root: groups(:used_canceled_free_group), eligible: false },
      discussion_template: { root: groups(:used_discussion_template_group), eligible: false },
      poll_template: { root: groups(:used_poll_template_group), eligible: false },
      membership_request: { root: groups(:used_membership_request_group), eligible: false },
      chatbot: { root: groups(:used_chatbot_group), eligible: false },
      tag: { root: groups(:used_tag_group), eligible: false },
      attachment: { root: groups(:used_attachment_group), eligible: false },
      recent_root: { root: groups(:used_recent_group), eligible: false },
      recent_subgroup: {
        root: groups(:used_recent_subgroup_tree),
        subgroup: groups(:used_recent_subgroup),
        eligible: false
      }
    }
  end
end

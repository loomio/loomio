require "test_helper"

class EnforceSingleLevelSubgroupsTest < ActiveSupport::TestCase
  test "database rejects grandchildren, self-parenting, and demoting a parent with subgroups" do
    root = groups(:orphan_group_tree)
    subgroup = groups(:orphan_subgroup)
    other = groups(:orphan_group)

    assert_raises(ActiveRecord::InvalidForeignKey) do
      Group.transaction(requires_new: true) { other.update_column(:parent_id, subgroup.id) }
    end

    assert_raises(ActiveRecord::InvalidForeignKey) do
      Group.transaction(requires_new: true) { other.update_column(:parent_id, other.id) }
    end

    assert_raises(ActiveRecord::InvalidForeignKey) do
      Group.transaction(requires_new: true) { root.update_column(:parent_id, other.id) }
    end

    # Moving a root with no subgroups under another root remains allowed.
    other.update_column(:parent_id, root.id)
    assert_equal root.id, other.reload.parent_id
  end
end

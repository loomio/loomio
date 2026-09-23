require "test_helper"
require Rails.root.join("db/migrate/support/tag_reference_integrity_cleanup")

class TagReferenceIntegrityCleanupTest < ActiveSupport::TestCase
  test "deletes orphan tags and taggings while preserving live records" do
    group = groups(:group)
    live_tag = Tag.create!(group: group, name: "live tag")
    now = Time.current
    live_tagging_id = Tagging.insert_all!([{
      tag_id: live_tag.id,
      taggable_type: "Group",
      taggable_id: group.id,
      created_at: now,
      updated_at: now
    }]).rows.first.first

    orphan_tag_id, orphan_tagging_id = ActiveRecord::Base.connection.disable_referential_integrity do
      orphan_tag_id = Tag.insert_all!([{
        group_id: Group.maximum(:id) + 1,
        name: "orphan tag",
        created_at: now,
        updated_at: now
      }]).rows.first.first
      orphan_tagging_id = Tagging.insert_all!([{
        tag_id: Tag.maximum(:id) + 1,
        taggable_type: "Group",
        taggable_id: group.id,
        created_at: now,
        updated_at: now
      }]).rows.first.first
      [ orphan_tag_id, orphan_tagging_id ]
    end

    result = TagReferenceIntegrityCleanup.run!(ActiveRecord::Base.connection)

    assert_equal({ taggings: 1, tags: 1 }, result)
    assert_not Tag.exists?(orphan_tag_id)
    assert_not Tagging.exists?(orphan_tagging_id)
    assert Tag.exists?(live_tag.id)
    assert Tagging.exists?(live_tagging_id)
  end
end

require_relative "support/tag_reference_integrity_cleanup"

class NormalizeTagReferenceIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    deleted = TagReferenceIntegrityCleanup.run!(connection)
    say "Deleted #{deleted[:taggings]} orphan taggings and #{deleted[:tags]} orphan tags"

    validate_foreign_key :tags, :groups, column: :group_id
    validate_foreign_key :taggings, :tags, column: :tag_id

    constraint_name = "tags_group_id_not_null"
    return unless check_constraint_exists?(:tags, name: constraint_name)

    validate_check_constraint :tags, name: constraint_name
    transaction do
      change_column_null :tags, :group_id, false
      remove_check_constraint :tags, name: constraint_name
    end
  end

  def down
    change_column_null :tags, :group_id, true
    add_check_constraint :tags,
                         "group_id IS NOT NULL",
                         name: "tags_group_id_not_null",
                         validate: false,
                         if_not_exists: true
  end
end

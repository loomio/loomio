class ValidateTopicForeignKeyOnDiscussions < ActiveRecord::Migration[8.0]
  def up
    # Validates the FK added (unvalidated) by AddTopicForeignKeyToDiscussions,
    # after DiscardTopiclessDiscussions has cleared the orphans. Validation scans
    # discussions under a SHARE UPDATE EXCLUSIVE lock, which does not block reads
    # or writes.
    validate_foreign_key :discussions, :topics
  end

  def down
    # Nothing to undo — the constraint is dropped by rolling back
    # AddTopicForeignKeyToDiscussions.
  end
end

class ValidateTopicForeignKeyOnPolls < ActiveRecord::Migration[8.0]
  def up
    # Validates the FK added (unvalidated) by AddTopicForeignKeyToPolls, after
    # DiscardTopiclessPolls has cleared the orphans. Validation scans polls under
    # a SHARE UPDATE EXCLUSIVE lock, which does not block reads or writes.
    validate_foreign_key :polls, :topics
  end

  def down
    # Nothing to undo — the constraint is dropped by rolling back
    # AddTopicForeignKeyToPolls.
  end
end

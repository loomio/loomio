class AddTopicForeignKeyToPolls < ActiveRecord::Migration[8.0]
  def change
    # A poll must always reference a real topic (its group/audience comes from
    # the topic). Historically nothing enforced this, so destroying a group/topic
    # left the polls behind with a dangling topic_id, and the closing-soon sweep
    # later crashed on poll.topic == nil.
    #
    # deferrable: :deferred checks the constraint at COMMIT, not per-statement.
    # This is required by GroupExportService.import, which inserts polls with
    # their *old* topic_id and remaps to the new ids later in the same
    # transaction; an immediately-checked FK would reject the intermediate state.
    # (NO ACTION rather than :restrict because RESTRICT is never deferrable — and
    # NO ACTION is equally protective: it still blocks deleting a topic that has
    # polls. The app destroys polls first via `Topic has_many :polls,
    # dependent: :destroy`, so legitimate teardown is unaffected.)
    #
    # validate: false adds the constraint without scanning existing rows (which
    # still contain orphans). DiscardTopiclessPolls cleans those up, then
    # ValidateTopicForeignKeyOnPolls validates under a non-blocking lock.
    add_foreign_key :polls, :topics, deferrable: :deferred, validate: false
  end
end

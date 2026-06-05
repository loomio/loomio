class AddTopicForeignKeyToDiscussions < ActiveRecord::Migration[8.0]
  def change
    # Mirror of AddTopicForeignKeyToPolls. A discussion must always reference a
    # real topic (its group/audience comes from the topic). Destroying a
    # group/topic previously left discussions behind with a dangling topic_id.
    #
    # deferrable: :deferred — checked at COMMIT, not per-statement — so
    # GroupExportService.import (insert with old topic_id, remap to new ids in
    # the same transaction) is unaffected. NO ACTION (not :restrict, which can't
    # be deferred) still blocks deleting a topic that has discussions; the app
    # destroys discussions first via `Topic has_many :discussions,
    # dependent: :destroy`.
    #
    # validate: false skips scanning existing (still-orphaned) rows;
    # DiscardTopiclessDiscussions cleans those up and
    # ValidateTopicForeignKeyOnDiscussions validates under a non-blocking lock.
    add_foreign_key :discussions, :topics, deferrable: :deferred, validate: false
  end
end

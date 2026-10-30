class LinkEventPollsToSourceOutcomes < ActiveRecord::Migration[8.1]
  def change
    # New references are enforced immediately without scanning historical polls.
    # Defer the check to commit so archives can restore polls before outcomes.
    add_foreign_key :polls, :outcomes, column: :source_outcome_id,
      on_delete: :nullify, deferrable: :deferred, validate: false
  end
end

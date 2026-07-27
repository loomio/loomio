class AddLegacyAnonymousVoteStorage < ActiveRecord::Migration[8.0]
  # This migration only prepares storage. Converting legacy stance data is an
  # irreversible operator action performed by the manual rake task.
  def change
    add_column :polls, :legacy_anonymous, :boolean, default: false, null: false
    change_column_null :anonymous_poll_voters, :group_member, true

    create_table :legacy_anonymous_vote_reasons, id: false do |t|
      t.uuid :anonymous_ballot_id, null: false, primary_key: true
      t.text :body, null: false
    end

    add_foreign_key :legacy_anonymous_vote_reasons,
                    :anonymous_ballots,
                    column: :anonymous_ballot_id,
                    on_delete: :cascade
  end
end

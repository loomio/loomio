class AddDetachedAnonymousVoting < ActiveRecord::Migration[7.2]
  def change
    add_column :polls, :voting_system, :integer, default: 0, null: false

    create_table :anonymous_poll_voters do |t|
      t.references :poll, null: false, foreign_key: true
      t.references :voter, null: false, foreign_key: { to_table: :users }
      t.references :inviter, null: true, foreign_key: { to_table: :users }
      t.boolean :group_member, null: false, default: false
      t.boolean :ballot_submitted, null: false, default: false
    end
    add_index :anonymous_poll_voters, [:poll_id, :voter_id], unique: true

    create_table :anonymous_ballots, id: :uuid, default: -> { "public.gen_random_uuid()" } do |t|
      t.references :poll, null: false, foreign_key: true
      t.boolean :none_of_the_above, null: false, default: false
    end

    create_table :anonymous_ballot_choices, id: false do |t|
      t.references :anonymous_ballot, type: :uuid, null: false, foreign_key: true
      t.references :poll_option, null: false, foreign_key: true
      t.integer :score, null: false, default: 1
    end
    add_index :anonymous_ballot_choices,
              [:anonymous_ballot_id, :poll_option_id],
              unique: true,
              name: "index_anonymous_ballot_choices_on_ballot_and_option"
  end
end

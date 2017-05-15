class ImprovePollSearchIndexing < ActiveRecord::Migration
  def change
    add_index :poll_communities, :poll_id
    add_index :poll_communities, :community_id
    add_index :polls, :discussion_id
    add_index :polls, :author_id
    add_index :stances, :poll_id
    add_index :stances, [:participant_id, :participant_type]
  end
end

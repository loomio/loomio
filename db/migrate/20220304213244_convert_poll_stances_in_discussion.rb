class ConvertPollStancesInDiscussion < ActiveRecord::Migration[6.1]
  def up
    execute "CREATE TABLE IF NOT EXISTS partition_sequences (key TEXT, id INTEGER, counter INTEGER DEFAULT 0, PRIMARY KEY(key, id))"
    Poll.where(stances_in_discussion: false).
         where("discussion_id is not null").pluck(:id).each do |poll_id|
      ConvertPollStancesInDiscussionWorker.perform_async(poll_id)
    end
  end

  def down
    execute "DROP TABLE IF EXISTS partition_sequences"
  end
end

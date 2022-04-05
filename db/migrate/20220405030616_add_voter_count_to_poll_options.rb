class AddVoterCountToPollOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :poll_options, :voter_count, :integer, null: false, default: 0
    Poll.pluck(:id).each do |id|
      UpdatePollCountsWorker.perform_async(id)
    end
  end
end

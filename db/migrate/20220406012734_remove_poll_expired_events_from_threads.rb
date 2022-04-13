class RemovePollExpiredEventsFromThreads < ActiveRecord::Migration[6.1]
  def change
    Poll.where('discussion_id is not null').order("id desc").pluck(:id).each do |id|
      RemovePollExpiredFromThreadsWorker.perform_async(id)
    end
  end
end

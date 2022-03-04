class ConvertPollStancesInDiscussion < ActiveRecord::Migration[6.1]
  def change
    Poll.where(stances_in_discussion: false).
         where("discussion_id is not null").pluck(:id).each do |poll_id|
      ConvertPollStancesInDiscussionWorker.perform_async(poll_id)
    end
  end
end

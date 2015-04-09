class PopulateParticipating < ActiveRecord::Migration
  def up
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Discussion.count )
    Discussion.reset_column_information
    Discussion.includes(:events).find_each(batch_size: 100) do |discussion|
      participant_ids = (discussion.events.pluck(:user_id) << discussion.author_id).compact.uniq
      DiscussionReader.where(user_id: participant_ids, discussion: discussion).update_all(participating: true)
      progress_bar.increment
    end
  end

  def down
  end
end

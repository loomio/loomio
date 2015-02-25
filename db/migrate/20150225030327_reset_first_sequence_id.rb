class ResetFirstSequenceId < ActiveRecord::Migration
  def create_progress_bar(total)
    ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                       progress_mark: "\e[32m/\e[0m",
                       total: total)
  end
  def change
    #first_sequence_id
    puts "Resetting first_sequence_id for all discussions"
    bar = create_progress_bar(Discussion.count)
    Event.select('DISTINCT ON (discussion_id) id, *').
          where('discussion_id is not null').
          order('discussion_id, events.created_at asc').each do |item|
      bar.increment
      Discussion.where(id: item.discussion_id).update_all(first_sequence_id: item.sequence_id)
    end
  end
end

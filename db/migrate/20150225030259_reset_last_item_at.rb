class ResetLastItemAt < ActiveRecord::Migration
  def create_progress_bar(total)
    ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                       progress_mark: "\e[32m/\e[0m",
                       total: total)
  end
  def change
    puts "Resetting last_item_at, last_sequence_id for all discussions"
    bar = create_progress_bar(Discussion.count)
    Event.select('DISTINCT ON (discussion_id) id, *').
          where('discussion_id is not null').
          order('discussion_id, events.created_at desc').each do |item|
      bar.increment
      raise item.inspect if item.sequence_id.nil?
      Discussion.where(id: item.discussion_id).update_all(last_item_at: item.created_at,
                                                          last_sequence_id: item.sequence_id || 0)
    end
  end
end

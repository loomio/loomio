class ResetLastActivityAt < ActiveRecord::Migration
  def create_progress_bar(total)
    ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                       progress_mark: "\e[32m/\e[0m",
                       total: total)
  end
  def change
    puts "Resetting last_activity_at for all discussions"
    bar = create_progress_bar(Discussion.count)
    Event.select('DISTINCT ON (discussion_id) id, *').
          where('discussion_id is not null').
          where(kind: Discussion::SALIENT_ITEM_KINDS).
          order('discussion_id, events.created_at desc').each do |item|
      bar.increment
      Discussion.where(id: item.discussion_id).update_all(last_activity_at: item.created_at)
    end
    Discussion.where(last_activity_at: nil).update_all('last_activity_at = created_at')
  end
end

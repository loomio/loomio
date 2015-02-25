class ResetDiscussionReaders < ActiveRecord::Migration
  def create_progress_bar(total)
    ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                       progress_mark: "\e[32m/\e[0m",
                       total: total)
  end
  def change
    discussion_ids = Discussion.pluck(:id)
    bar = create_progress_bar(discussion_ids.size)
    discussion_ids.each do |id|
      bar.increment
      DiscussionReader.where(discussion_id: id).find_each do |dr|
        dr.update_attribute(:read_salient_items_count, dr.read_salient_items.count)
      end
    end
  end
end

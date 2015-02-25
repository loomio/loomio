class ResetDiscussionManagedValues < ActiveRecord::Migration
  def create_progress_bar(total)
    ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                       progress_mark: "\e[32m/\e[0m",
                       total: total)
  end

  def change
    raise "migration does not work" if Event.where('discussion_id is not null').where('sequence_id is null').any?

    puts "Resetting items_count, salient_items_count, comments_count for all discussions"
    bar = create_progress_bar(Discussion.count)
    Discussion.find_each do |discussion|
      bar.increment
      Discussion.where(id: discussion.id).update_all(items_count: discussion.items.count,
                                                     salient_items_count: discussion.salient_items.count,
                                                     comments_count: discussion.comments.count)
    end

  end
end

class ResetLastCommentAt < ActiveRecord::Migration
  def create_progress_bar(total)
    ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                       progress_mark: "\e[32m/\e[0m",
                       total: total)
  end
  def change
    puts "Resetting last_comment_at for all discussions"
    bar = create_progress_bar(Discussion.count)
    Comment.select('DISTINCT ON (discussion_id) id, *').order('discussion_id, comments.created_at desc').each do |comment|
      bar.increment
      Discussion.where(id: comment.discussion_id).update_all(last_comment_at: comment.created_at)
    end
  end
end

class DeleteDanglingLikes < ActiveRecord::Migration
  def up
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: CommentVote.count )
    CommentVote.find_each do |cv|
      progress_bar.increment
      cv.destroy if cv.user.nil?
    end
  end

  def down
  end
end

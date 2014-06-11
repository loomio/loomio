class AddCommentsCountToDiscussions < ActiveRecord::Migration
  class Discsussion < ActiveRecord::Base
    has_many :comments
  end

  class Comment < ActiveRecord::Base
    belongs_to :discussion
  end

  def up
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Discussion.count )
    Discussion.reset_column_information
    Discussion.find_each do |discussion|
      discussion.update_attribute(:comments_count, discussion.comments.count)
      progress_bar.increment
    end
  end

  def down
  end
end

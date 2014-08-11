class AddCommentsCountToDiscussions < ActiveRecord::Migration
  class Discsussion < ActiveRecord::Base
    has_many :comments
  end

  class Comment < ActiveRecord::Base
    belongs_to :discussion, counter_cache: true
  end

  def up
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Discussion.count )
    Discussion.reset_column_information
    Discussion.find_each do |discussion|
      Discussion.reset_counters(discussion.id, :comments)
      progress_bar.increment
    end
  end

  def down
  end
end

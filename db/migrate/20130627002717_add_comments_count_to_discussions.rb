class AddCommentsCountToDiscussions < ActiveRecord::Migration
  class Discsussion < ActiveRecord::Base
    has_many :comments
  end

  class Comment < ActiveRecord::Base
    belongs_to :discussion
  end

  def up
    Discussion.reset_column_information
    Discussion.find_each do |discussion|
      discussion.update_attribute(:comments_count, discussion.comments.count)
    end
  end

  def down
  end
end

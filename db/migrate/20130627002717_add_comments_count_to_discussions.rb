class AddCommentsCountToDiscussions < ActiveRecord::Migration
  class Discsussion < ActiveRecord::Base
    has_many :comments
  end

  class Comment < ActiveRecord::Base
    belongs_to :discussion, counter_cache: true
  end

  def up
    Discussion.reset_column_information
    Discussion.find_each do |discussion|
      Discussion.reset_counters(discussion.id, :comments)
    end
  end

  def down
  end
end

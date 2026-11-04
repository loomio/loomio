class UseThreeLevelDiscussionThreads < ActiveRecord::Migration[7.2]
  def up
    change_column_default :discussion_templates, :max_depth, from: 2, to: 3
    execute "UPDATE discussion_templates SET max_depth = 3 WHERE max_depth = 2"
    execute "UPDATE topics SET max_depth = 3 WHERE max_depth = 2"
  end

  def down
    change_column_default :discussion_templates, :max_depth, from: 3, to: 2
  end
end

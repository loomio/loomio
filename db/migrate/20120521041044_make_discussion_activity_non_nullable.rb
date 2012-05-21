class MakeDiscussionActivityNonNullable < ActiveRecord::Migration
  def up
    Discussion.where("activity is NULL").each do |discussion|
      discussion.activity = 0
      discussion.save
    end
    change_column :discussions, :activity, :integer, :default => 0, :null => false
  end

  def down
  end
end

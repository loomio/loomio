class DropUnusedCounterCaches < ActiveRecord::Migration[8.1]
  # Nothing in the application reads these counters, yet saves to polls,
  # discussions, memberships, topic readers and templates kept recounting them.
  # Topic closed_polls_count had not been maintained since the topics refactor.
  def change
    remove_column :groups, :closed_polls_count, :integer, default: 0, null: false
    remove_column :groups, :delegates_count, :integer, default: 0, null: false
    remove_column :groups, :discussion_templates_count, :integer, default: 0, null: false
    remove_column :topics, :closed_polls_count, :integer, default: 0, null: false
    remove_column :topics, :members_count, :integer
    remove_column :tags, :taggings_count, :integer, default: 0, null: false
  end
end

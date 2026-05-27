class AddTopicThreadSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :allow_concurrent_polls, :boolean, default: false, null: false
    add_column :topics, :active_polls_count, :integer, default: 0, null: false
    add_column :topics, :allow_comments, :boolean, default: true, null: false
    add_column :topics, :allow_reactions, :boolean, default: true, null: false

    add_column :discussion_templates, :allow_concurrent_polls, :boolean, default: false, null: false
    add_column :discussion_templates, :allow_comments, :boolean, default: true, null: false
    add_column :discussion_templates, :allow_reactions, :boolean, default: true, null: false

    add_column :poll_templates, :allow_comments, :boolean, default: true, null: false
    add_column :poll_templates, :allow_reactions, :boolean, default: true, null: false
  end
end

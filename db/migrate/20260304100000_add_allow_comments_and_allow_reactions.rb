class AddAllowCommentsAndAllowReactions < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :allow_comments, :boolean, default: true, null: false
    add_column :topics, :allow_reactions, :boolean, default: true, null: false
    add_column :poll_templates, :allow_comments, :boolean, default: true, null: false
    add_column :poll_templates, :allow_reactions, :boolean, default: true, null: false
    add_column :discussion_templates, :allow_comments, :boolean, default: true, null: false
    add_column :discussion_templates, :allow_reactions, :boolean, default: true, null: false
  end
end

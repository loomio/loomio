class ReplaceTemplateDiscardedWithHidden < ActiveRecord::Migration[8.1]
  def change
    rename_column :discussion_templates, :discarded_at, :hidden_at
    rename_column :discussion_templates, :discarded_by, :hider_id
    add_column :discussion_templates, :discarded_at, :datetime
    add_column :discussion_templates, :discarded_by, :integer
    add_index :discussion_templates, :discarded_at
    add_index :discussion_templates, :discarded_by

    rename_column :poll_templates, :discarded_at, :hidden_at
    add_column :poll_templates, :hider_id, :integer
    add_index :poll_templates, :hider_id
    add_column :poll_templates, :discarded_at, :datetime
    add_column :poll_templates, :discarded_by, :integer
    add_index :poll_templates, :discarded_at
    add_index :poll_templates, :discarded_by
  end
end

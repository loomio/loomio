class AddLinkPreviewsToRichTextModels < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :link_previews, :jsonb, default: {}, null: false
    add_column :discussions, :link_previews, :jsonb, default: {}, null: false
    add_column :polls, :link_previews, :jsonb, default: {}, null: false
    add_column :groups, :link_previews, :jsonb, default: {}, null: false
    add_column :users, :link_previews, :jsonb, default: {}, null: false
    add_column :stances, :link_previews, :jsonb, default: {}, null: false
    add_column :outcomes, :link_previews, :jsonb, default: {}, null: false
  end
end

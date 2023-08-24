class AddTitlePlaceholderToBothTemplatesTables < ActiveRecord::Migration[7.0]
  def change
    add_column :discussion_templates, :title_placeholder, :string
    add_column :poll_templates, :title_placeholder, :string
    remove_column :poll_templates, :process_url
  end
end

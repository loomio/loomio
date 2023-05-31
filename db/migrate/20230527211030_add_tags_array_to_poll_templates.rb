class AddTagsArrayToPollTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_templates, :tags, :string, array: true, default: []
  end
end

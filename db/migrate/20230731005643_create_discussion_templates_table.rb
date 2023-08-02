class CreateDiscussionTemplatesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :discussion_templates do |t|
      t.string :key
      t.integer :group_id
      t.integer :position
      t.integer :author_id
      t.string :title
      t.text :description
      t.string :description_format, limit: 10, default: "md", null: false
      t.string :process_name
      t.string :process_subtitle
      t.string :process_introduction
      t.string :process_introduction_format, default: "md", null: false
      t.jsonb "attachments", default: [], null: false
      t.integer "max_depth", default: 2, null: false
      t.boolean "newest_first", default: false, null: false
      t.datetime "discarded_at", precision: nil
      t.integer "discarded_by"
      t.string "content_locale"
      t.jsonb "link_previews", default: [], null: false
      t.integer "source_template_id"
      t.string "tags", default: [], array: true
      t.index ["discarded_at"], name: "index_discussion_templates_on_discarded_at"
      t.timestamps
    end
  end
end

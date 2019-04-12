class AddTags < ActiveRecord::Migration[5.2]
  def change
    unless table_exists? :tags
      create_table :tags do |table|
        table.belongs_to :group
        table.string :name
        table.string :color
        table.integer :discussion_tags_count, default: 0
        table.timestamps
      end
    end

    unless table_exists? :discussion_tags
      create_table :discussion_tags do |table|
        table.belongs_to :tag
        table.belongs_to :discussion
        table.timestamps
      end
    end
  end
end

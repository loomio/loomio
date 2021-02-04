class CleanUpTagsTaggings < ActiveRecord::Migration[5.2]
  def change
    Tag.order(:id).each do |tag|
      Tag.where("id != ?", tag.id).where(name: tag.name).each do |dupe|
        Tagging.where(tag_id: dupe.id).update_all(tag_id: tag.id)
        dupe.delete
      end
    end
    add_index :tags, [:group_id, :name], unique: true
  end
end

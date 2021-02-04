class CleanUpTagsTaggings < ActiveRecord::Migration[5.2]
  def change
    keys = []
    Tag.order(:id).each do |tag|
      next if keys.include? "#{tag.group_id}-#{tag.name}"
      keys.push "#{tag.group_id}-#{tag.name}"
      Tag.where(group_id: tag.group_id, name: tag.name).where("id != ?", tag.id).each do |dupe|
        Tagging.where(tag_id: dupe.id).update_all(tag_id: tag.id)
        dupe.delete
      end
    end
    add_index :tags, [:group_id, :name], unique: true
  end
end

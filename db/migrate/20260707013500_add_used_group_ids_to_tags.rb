class AddUsedGroupIdsToTags < ActiveRecord::Migration[8.0]
  require 'set'

  class MigrationGroup < ActiveRecord::Base
    self.table_name = "groups"
  end

  class MigrationTag < ActiveRecord::Base
    self.table_name = "tags"
  end

  class MigrationTopic < ActiveRecord::Base
    self.table_name = "topics"
  end

  def up
    add_column :tags, :used_group_ids, :integer, array: true, default: [], null: false
    add_index :tags, :used_group_ids, using: :gin

    backfill_used_group_ids
  end

  def down
    remove_index :tags, :used_group_ids
    remove_column :tags, :used_group_ids
  end

  private

  def backfill_used_group_ids
    MigrationGroup.distinct.pluck(Arel.sql("COALESCE(parent_id, id)")).compact.each do |parent_id|
      group_ids = MigrationGroup.where("id = ? OR parent_id = ?", parent_id, parent_id).pluck(:id)

      names_by_key = {}
      used_group_ids_by_key = {}

      MigrationTopic.where(group_id: group_ids).pluck(:group_id, :tags).each do |topic_group_id, tags|
        clean_tag_names(tags).each do |name|
          key = normalized_name(name)
          names_by_key[key] ||= name
          used_group_ids_by_key[key] ||= Set.new
          used_group_ids_by_key[key].add(topic_group_id)
        end
      end

      legacy_tags = MigrationTag.where(group_id: group_ids - [parent_id]).to_a
      legacy_color_by_key = legacy_tags.each_with_object({}) do |tag, colors|
        colors[normalized_name(tag.name)] ||= tag.color
      end

      actual_tag_by_key = MigrationTag.where(group_id: parent_id).index_by { |tag| normalized_name(tag.name) }
      missing_keys = names_by_key.keys - actual_tag_by_key.keys
      now = Time.current

      missing_keys.each do |key|
        MigrationTag.create!(
          group_id: parent_id,
          name: names_by_key[key],
          color: legacy_color_by_key[key],
          created_at: now,
          updated_at: now
        )
      end

      MigrationTag.where(id: legacy_tags.map(&:id)).destroy_all

      MigrationTag.where(group_id: parent_id).find_each do |tag|
        key = normalized_name(tag.name)
        tag.update_columns(
          used_group_ids: Array(used_group_ids_by_key[key]).map(&:to_i).sort,
          updated_at: now
        )
      end
    end
  end

  def clean_tag_names(names)
    seen = {}
    Array(names).filter_map do |name|
      clean = name.to_s.split.join(" ")
      key = normalized_name(clean)
      next if key.blank? || seen[key]

      seen[key] = true
      clean
    end
  end

  def normalized_name(name)
    name.to_s.split.join(" ").downcase
  end
end

# Merge tags that only differ by whitespace/case within the same group.
#
# tags.name is citext (case-insensitive), but before whitespace was stripped
# on write (TopicService#update_tags, TagService's count-aggregation upserts),
# look-alike rows like "Community Energy" and "Community Energy " could
# coexist - they render identically in the UI, so deleting one left an
# indistinguishable duplicate behind and looked like the delete silently
# failed. Self-contained (not referencing TagService/Tag/Topic) so this stays
# runnable as-is regardless of how those classes evolve later.
class GroomDuplicateTags < ActiveRecord::Migration[8.0]
  class MigrationTag < ActiveRecord::Base
    self.table_name = "tags"
  end

  class MigrationTopic < ActiveRecord::Base
    self.table_name = "topics"
  end

  def up
    MigrationTag.distinct.pluck(:group_id).each do |group_id|
      duplicate_groups = MigrationTag.where(group_id: group_id)
                                      .group_by { |tag| normalized_name(tag.name) }
                                      .values
                                      .select { |tags| tags.length > 1 }

      duplicate_groups.each do |tags|
        canonical = tags.max_by { |tag| [tag.taggings_count.to_i, -tag.id] }

        (tags - [canonical]).each do |dupe|
          MigrationTopic.where(group_id: group_id)
                        .where("topics.tags @> ARRAY[?]::varchar[]", dupe.name)
                        .find_each do |topic|
            topic.update_column(:tags, ((topic.tags - [dupe.name]) + [canonical.name]).uniq)
          end

          canonical.update_columns(
            taggings_count: canonical.taggings_count.to_i + dupe.taggings_count.to_i,
            org_taggings_count: canonical.org_taggings_count.to_i + dupe.org_taggings_count.to_i
          )
          dupe.destroy!
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def normalized_name(name)
    name.to_s.strip.downcase
  end
end

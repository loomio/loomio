class Queries::UsersByVolumeQuery
  def self.normal_or_loud(model)
    base_query(model).where(volume_where(mode: :greater_than), volume: DiscussionReader.volumes[:normal])
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(model) {
      base_query(model).where(volume_where, volume: DiscussionReader.volumes[volume])
    }
  end

  private

  def self.base_query(model)
    User.active
        .distinct
        .joins(membership_join(model))
        .joins(reader_join(model))
        .where.not('memberships.id': nil)
        .where('memberships.archived_at': nil)
  end

  def self.volume_where(mode: :equal_to)
    operator = mode == :equal_to ? '=' : '>='
    "dr.volume #{operator} :volume OR (dr.volume IS NULL AND memberships.volume #{operator} :volume)"
  end

  def self.reader_join(model)
    clause = model.respond_to?(:discussion) ? "= #{model.discussion.id.to_i}" : " IS NULL"
    "LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id #{clause})"
  end

  def self.membership_join(model)
    "LEFT OUTER JOIN memberships ON (memberships.archived_at IS NULL AND memberships.user_id = users.id AND memberships.group_id = #{model.group.id.to_i})"
  end
end

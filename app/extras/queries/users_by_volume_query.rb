class Queries::UsersByVolumeQuery
  def self.normal_or_loud(*models)
    base_query(models.compact, mode: :greater_than, volume: DiscussionReader.volumes[:normal])
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(*models) {
      base_query(models.compact, mode: :equal_to, volume: DiscussionReader.volumes[volume])
    }
  end

  private

  def self.base_query(models, mode:, volume:)
    return User.none unless models.present?
    User.active.distinct.from("(#{models.map do
      |m| model_query(m, mode: mode, volume: volume).to_sql
    end.compact.join(" UNION ")}) as users")
  end

  def self.model_query(model, mode:, volume:)
    return User.none unless model
    User.joins(membership_join(model))
        .joins(reader_join(model))
        .where.not('m.id': nil)
        .where('m.archived_at': nil)
        .where(volume_where(mode: mode), volume: volume)
  end

  def self.volume_where(mode: :equal_to)
    operator = mode == :equal_to ? '=' : '>='
    "dr.volume #{operator} :volume OR (dr.volume IS NULL AND m.volume #{operator} :volume)"
  end

  def self.reader_join(model)
    clause = model.respond_to?(:discussion) ? "= #{model.discussion.id.to_i}" : " IS NULL"
    "LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id #{clause})"
  end

  def self.membership_join(model)
    "LEFT OUTER JOIN memberships m ON (m.user_id = users.id AND m.group_id = #{model.group.id.to_i})"
  end
end

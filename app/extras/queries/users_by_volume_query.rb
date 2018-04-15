class Queries::UsersByVolumeQuery
  def self.normal_or_loud(model)
    users_by_volume(model, '>=', DiscussionReader.volumes[:normal])
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(model) {
      users_by_volume(model, '=', DiscussionReader.volumes[volume])
    }
  end

  private

  # override with logic for a particular model
  def self.users_by_volume(model, operator, volume)
    return User.none if model.nil?

    rel = User.active.distinct.joins_formal_memberships(model)

    if model.respond_to?(:discussion_id)
      rel = rel.joins_readers(model).
      joins_guest_memberships(model).
      where("
          dr.volume #{operator} :volume OR
          (dr.volume IS NULL AND gm.volume #{operator} :volume) OR
          (dr.volume IS NULL AND gm.volume IS NULL AND fm.volume #{operator} :volume)
          ", volume: volume)
      byebug
      rel
    else
      rel.where("fm.volume #{operator} :volume", volume: volume)
    end
  end
end

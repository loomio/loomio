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

  def self.users_by_volume(model, operator, volume)
    return User.none if model.nil?
    rel = User.active.distinct
    if model.is_a?(Group)
      rel.joins(:memberships)
         .where("memberships.group_id": model.id)
         .where("memberships.volume #{operator} ?", volume)
    else
      rel.joins_readers(model)
         .joins_guest_memberships(model)
         .joins_formal_memberships(model)
         .where("((gm.id IS NOT NULL OR fm.id IS NOT NULL) AND dr.volume #{operator} :volume) OR
          (dr.volume IS NULL AND gm.volume #{operator} :volume) OR
          (dr.volume IS NULL AND gm.volume IS NULL AND fm.volume #{operator} :volume)
          ", volume: volume)
    end
  end
end

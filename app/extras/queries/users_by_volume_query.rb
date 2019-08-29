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
         .where("gm.id is NOT NULL OR fm.id is NOT NULL")
         .where("coalesce(dr.volume, fm.volume, gm.volume, 2) #{operator} :volume", volume: volume)
    end
  end
end

class Queries::UsersByVolumeQuery
  def self.normal_or_loud(model)
    users_by_volume(model, '>=', normal_volume)
  end

  %w(mute quiet normal loud).map(&:to_sym).each do |volume|
    define_singleton_method volume, ->(model) {
      users_by_volume(model, '=', normal_volume)
    }
  end

  private

  # override with logic for a particular model
  def self.users_by_volume(model, operator, volume)
    User.active.distinct
        .joins_on_readers(discussion)
        .joins_on_guest_memberships(discussion)
        .joins_on_formal_memberships(discussion)
        .where("
           dr.volume #{operator} :volume OR
          (dr.volume IS NULL AND gm.volume #{operator} :volume) OR
          (dr.volume IS NULL AND gm.volume IS NULL AND fm.volume #{operator} :volume)
        ", volume: volume)
  end

  def self.normal_volume
    DiscussionReader.volumes[:normal]
  end
end

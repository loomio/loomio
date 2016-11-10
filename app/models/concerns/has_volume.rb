module HasVolume
  extend ActiveSupport::Concern

  included do
    enum volume: [:mute, :quiet, :normal, :loud]
    scope :volume, ->(volume) { where(volume: volumes[volume]) }
  end

  def set_volume!(volume)
    if volume_is_valid?(volume)
      update_attribute :volume, volume
    else
      self.errors.add :volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

  def volume_is_valid?(volume)
    self.class.volumes.include?(volume)
  end

  def volume_is_loud?
    volume.to_s == 'loud'
  end

  def volume_is_normal?
    volume.to_s == 'normal'
  end

  def volume_is_quiet?
    volume.to_s == 'quiet'
  end

  def volume_is_mute?
    volume.to_s == 'mute'
  end
end

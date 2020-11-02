module HasVolume
  extend ActiveSupport::Concern

  included do
    enum volume: {mute: 0, quiet: 1, normal: 2, loud: 3}
    scope :volume,          ->(volume) { where(volume: volumes[volume]) }
    scope :volume_at_least, ->(volume) { where('volume >= ?', volumes[volume]) }
    scope :email_notifications, -> { where('volume >= ?', volumes[:normal]) }
    scope :app_notifications, -> { where('volume >= ?', volumes[:quiet]) }
  end

  def set_volume!(volume, persist: true)
    if self.class.volumes.include?(volume)
      self.volume = volume
      save if persist
    else
      self.errors.add :volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

  def volume_is_normal_or_loud?
    volume_is_normal? || volume_is_loud?
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

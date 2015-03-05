module HasVolume
  extend ActiveSupport::Concern

  included do
    enum volume: [:mute, :normal, :email]
    scope :volume, ->(volume) { where(volume: volumes[volume]) }
  end

  def set_volume!(volume)
    if self.class.volumes.include? volume
      update_attribute :volume, volume
    else
      self.errors.add :volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

  def volume_is_email?
    volume.to_s == 'email'
  end

  def volume_is_normal?
    volume.to_s == 'normal'
  end

end

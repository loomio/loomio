module HasVolume
  extend ActiveSupport::Concern

  included do
    enum volume: [:mute, :normal, :email]
    scope :volume, ->(volume) { where(volume: volumes[volume]) }
  end

  def change_volume!(volume)
    if self.class.volumes.include? volume
      update_attribute :volume, volume
    else
      self.errors.add :volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

end

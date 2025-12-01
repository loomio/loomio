module HasVolume
  extend ActiveSupport::Concern

  included do
    enum :email_volume, {mute: 0, quiet: 1, normal: 2, loud: 3}, prefix: :email
    enum :push_volume, {mute: 0, quiet: 1, normal: 2, loud: 3}, prefix: :push
    
    scope :email_volume,          ->(volume) { where(email_volume: email_volumes[volume]) }
    scope :email_volume_at_least, ->(volume) { where('email_volume >= ?', email_volumes[volume]) }
    scope :email_notifications, -> { where('email_volume >= ?', email_volumes[:normal]) }
    scope :app_notifications, -> { where('email_volume >= ?', email_volumes[:quiet]) }
    
    scope :push_volume,          ->(volume) { where(push_volume: push_volumes[volume]) }
    scope :push_volume_at_least, ->(volume) { where('push_volume >= ?', push_volumes[volume]) }
    scope :push_notifications, -> { where('push_volume >= ?', push_volumes[:normal]) }
  end

  def set_volume!(volume, persist: true)
    if self.class.email_volumes.include?(volume)
      self.email_volume = volume
      save if persist
    else
      self.errors.add :email_volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

  def set_email_volume!(volume, persist: true)
    if self.class.email_volumes.include?(volume)
      self.email_volume = volume
      save if persist
    else
      self.errors.add :email_volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

  def set_push_volume!(volume, persist: true)
    if self.class.push_volumes.include?(volume)
      self.push_volume = volume
      save if persist
    else
      self.errors.add :push_volume, I18n.t(:"activerecord.errors.messages.invalid")
      false
    end
  end

  # Legacy methods for backward compatibility (map to email_volume)
  def volume
    email_volume
  end

  def volume=(val)
    self.email_volume = val
  end

  def volume_is_normal_or_loud?
    email_volume_is_normal_or_loud?
  end

  def volume_is_loud?
    email_volume_is_loud?
  end

  def volume_is_normal?
    email_volume_is_normal?
  end

  def volume_is_quiet?
    email_volume_is_quiet?
  end

  def volume_is_mute?
    email_volume_is_mute?
  end

  # New email_volume helper methods
  def email_volume_is_normal_or_loud?
    email_volume_is_normal? || email_volume_is_loud?
  end

  def email_volume_is_loud?
    email_volume.to_s == 'loud'
  end

  def email_volume_is_normal?
    email_volume.to_s == 'normal'
  end

  def email_volume_is_quiet?
    email_volume.to_s == 'quiet'
  end

  def email_volume_is_mute?
    email_volume.to_s == 'mute'
  end

  # New push_volume helper methods
  def push_volume_is_normal_or_loud?
    push_volume_is_normal? || push_volume_is_loud?
  end

  def push_volume_is_loud?
    push_volume.to_s == 'loud'
  end

  def push_volume_is_normal?
    push_volume.to_s == 'normal'
  end

  def push_volume_is_quiet?
    push_volume.to_s == 'quiet'
  end

  def push_volume_is_mute?
    push_volume.to_s == 'mute'
  end
end

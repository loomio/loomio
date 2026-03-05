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

  def email_volume_is_normal_or_loud?
    email_normal? || email_loud?
  end

  def push_volume_is_normal_or_loud?
    push_normal? || push_loud?
  end
end

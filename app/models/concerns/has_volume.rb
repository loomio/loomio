module HasVolume
  extend ActiveSupport::Concern

  included do
    enum :volume_email, { quiet: 1, normal: 2, loud: 3 }, prefix: :email
    enum :volume_push, { quiet: 1, normal: 2, loud: 3 }, prefix: :push

    scope :email_notifications, -> { where(volume_email: volume_emails[:normal]..) }
    scope :push_notifications, -> { where(volume_push: volume_pushes[:normal]..) }
  end

  # Email and push are independent delivery volumes. A muted channel is not
  # delivered; normal sends directed notifications and loud sends all activity.
  def set_volume!(email:, push:, persist: true)
    unless self.class.volume_emails.key?(email.to_s)
      errors.add :volume_email, I18n.t(:"activerecord.errors.messages.invalid")
      return false
    end
    unless self.class.volume_pushes.key?(push.to_s)
      errors.add :volume_push, I18n.t(:"activerecord.errors.messages.invalid")
      return false
    end

    self.volume_email = email
    self.volume_push = push
    persist ? save : true
  end

  def email_enabled?
    email_normal? || email_loud?
  end

  def push_enabled?
    push_normal? || push_loud?
  end
end

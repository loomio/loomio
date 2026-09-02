module HasVolume
  extend ActiveSupport::Concern

  included do
    enum :volume_email, { quiet: 1, normal: 2, loud: 3 }, prefix: :email
    enum :volume_push, { quiet: 1, normal: 2, loud: 3 }, prefix: :push

    scope :email_enabled, -> { where.not(volume_email: volume_emails[:quiet]) }
    scope :push_enabled, -> { where.not(volume_push: volume_pushes[:quiet]) }
  end

  # Email and push are independent immediate-delivery volumes. Quiet leaves
  # activity for the app and digest; normal sends directed notifications and
  # loud sends all activity.
  def set_volume!(email: nil, push: nil, persist: true)
    if email.nil? && push.nil?
      errors.add :volume_email, I18n.t(:"activerecord.errors.messages.invalid")
      return false
    end
    if email && !self.class.volume_emails.key?(email.to_s)
      errors.add :volume_email, I18n.t(:"activerecord.errors.messages.invalid")
      return false
    end
    if push && !self.class.volume_pushes.key?(push.to_s)
      errors.add :volume_push, I18n.t(:"activerecord.errors.messages.invalid")
      return false
    end

    self.volume_email = email if email
    self.volume_push = push if push
    persist ? save : true
  end

  def email_enabled?
    email_normal? || email_loud?
  end

  def push_enabled?
    push_normal? || push_loud?
  end
end

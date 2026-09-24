class EmailChangeService
  EXPIRATION = 24.hours

  class InvalidConfirmation < StandardError; end

  def self.request(user:, actor:, email:)
    actor.ability.authorize! :update, user
    raise CanCan::AccessDenied if actor != user || actor.restricted || UserService.disable_edit_user_profile?

    email = email.to_s.strip
    user.errors.add(:email_change_pending, I18n.t('user.error.email_change_same')) if email.casecmp?(user.email.to_s)
    user.errors.add(:email_change_pending, :taken) if User.where(email: email).where.not(id: user.id).exists?
    raise ActiveRecord::RecordInvalid, user if user.errors.any?

    # Saving the pending address first binds the signed link to this exact
    # request. A later request replaces the address or timestamp, invalidating
    # every earlier confirmation link without changing the active login email.
    token = user.with_lock do
      user.update!(email_change_pending: email, email_change_requested_at: Time.current)
      user.signed_id(purpose: confirmation_purpose(user), expires_in: EXPIRATION)
    end
    UserMailer.email_change_confirmation(user.id, email, token).deliver_later
    UserMailer.email_change_requested(user.id, user.email, email).deliver_later
    user
  end

  def self.valid_confirmation?(user:, token:)
    return false if user.email_change_pending.blank? || user.email_change_requested_at.blank?

    User.find_signed(token, purpose: confirmation_purpose(user)) == user
  end

  def self.confirm(user:, token:)
    raise CanCan::AccessDenied if UserService.disable_edit_user_profile?

    old_email = nil
    new_email = nil
    user.with_lock do
      raise InvalidConfirmation unless valid_confirmation?(user: user, token: token)

      new_email = user.email_change_pending
      old_email = user.email
      user.update!(email: new_email, email_verified: true, email_change_pending: nil, email_change_requested_at: nil)
    end
    UserMailer.email_change_completed(user.id, old_email, new_email).deliver_later
    user
  end

  def self.confirmation_purpose(user)
    "email_change:#{user.email_change_pending}:#{user.email_change_requested_at.utc.iso8601(6)}"
  end
  private_class_method :confirmation_purpose
end

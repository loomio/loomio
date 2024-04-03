class RedactUserWorker
  include Sidekiq::Worker

  # we deactivate and redact the user
  def perform(user_id, actor_id, send_email = true)
    user = User.find_by!(id:user_id)
    email = user.email
    locale = user.locale
    deactivated_at = user.deactivated_at || DateTime.now
    group_ids = Membership.where(user_id: user_id).pluck(:group_id)

    user.uploaded_avatar.purge_later
    
    User.transaction do
      # set an email_sha256 so we can identify redacted accounts if someone provides an email

      User.where(id: user_id).update_all(
        is_admin: false,
        api_key: nil,
        secret_token: nil,
        name: nil,
        email: nil,
        short_bio: '',
        username: nil,
        experiences: {},
        avatar_kind: "initials",
        avatar_initials: nil,
        country: nil,
        region: nil,
        city: nil,
        location: '',
        email_newsletter: false,
        unlock_token: nil,
        current_sign_in_ip: nil,
        last_sign_in_ip: nil,
        encrypted_password: nil,
        reset_password_token: nil,
        reset_password_sent_at: nil,
        unsubscribe_token: nil,
        detected_locale: nil,
        email_verified: false,
        legal_accepted_at: nil,
        email_sha256: Digest::SHA256.hexdigest(email),
        deactivated_at: deactivated_at,
        deactivator_id: actor_id
      )

      PaperTrail::Version.where(item_type: 'User', item_id: user_id).delete_all
      Identities::Base.where(user_id: user_id).delete_all
      MembershipRequest.where(requestor_id: user_id, responded_at: nil).delete_all
      NewsletterService.unsubscribe(email)
    end

    Group.where(id: group_ids).map(&:update_memberships_count)
    UserMailer.redacted(email, locale).deliver_later if send_email
    SearchService.reindex_by_author_id(user.id)
  end
end

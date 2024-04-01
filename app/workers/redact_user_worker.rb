class RedactUserWorker
  include Sidekiq::Worker

  # we deactivate and redact the user
  def perform(user_id, actor_id)
    user = User.find(user_id)
    email = user.email
    locale = user.locale
    deactivated_at = user.deactivated_at || DateTime.now
    group_ids = Membership.where(user_id: user_id).pluck(:group_id)

    User.transaction do
      # set an email_sha256 so we can identify redacted accounts if someone provides an email
      user.update(
        name: nil,
        email: "deleted-user-#{SecureRandom.uuid}@example.com",
        short_bio: '',
        username: nil,
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
        legal_accepted_at: false,
        email_sha256: Digest::SHA256.hexdigest(email),
        deactivated_at: deactivated_at,
        deactivator_id: actor_id
      )

      PaperTrail::Version.where(item_type: 'User', item_id: user_id).delete_all
      Identities::Base.where(user_id: user_id).delete_all
      MembershipRequest.where(requestor_id: user_id, responded_at: nil).delete_all
    end

    Group.where(id: group_ids).map(&:update_memberships_count)
    UserMailer.deleted(email, user.email, locale).deliver_later
    SearchService.reindex_by_author_id(user.id)
  end
end

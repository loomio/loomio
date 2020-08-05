class DeactivateUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    User.transaction do
      email = user.email
      locale = user.locale

      user.update_attributes(name: nil,
                             email: "deactivated-user-#{SecureRandom.uuid}@example.com",
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
                             deactivated_at: Time.now)

      Identities::Base.where(user_id: user_id).delete_all

      Membership.where(user_id: user_id).update_all(archived_at: Time.now)

      group_ids = Membership.where(user_id: user_id).pluck(:group_id)
      Group.where(id: group_ids).map(&:update_memberships_count)

      MembershipRequest.where(requestor_id: user_id, responded_at: nil).destroy_all
      Ahoy::Message.where(user_id: user_id).delete_all
      UserMailer.deactivated(email, user.email, locale).deliver_now
    end
  end
end

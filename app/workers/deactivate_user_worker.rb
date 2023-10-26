class DeactivateUserWorker
  include Sidekiq::Worker

  def perform(user_id, actor_id)
    user = User.find(user_id)
    deactivated_at = DateTime.now

    User.transaction do

      if AppConfig.app_features[:scrub_user_deactivate]
        email = user.email
        locale = user.locale

        user.update(
          name: nil,
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
          deactivated_at: deactivated_at,
          deactivator_id: actor_id
        )
        UserMailer.deactivated(email, user.email, locale).deliver_later
      else
        user.update(deactivated_at: deactivated_at, deactivator_id: actor_id)
      end

      Identities::Base.where(user_id: user_id).delete_all

      group_ids = Membership.where(user_id: user_id).pluck(:group_id)
      Group.where(id: group_ids).map(&:update_memberships_count)

      MembershipRequest.where(requestor_id: user_id, responded_at: nil).destroy_all
    end
    
    SearchService.reindex_by_author_id(user.id)
  end
end

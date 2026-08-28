class PushSubscriptionService
  ACTIVE_COUNT_MAX = 20

  def self.create_or_update!(session:, params:, user_agent:)
    user = session.user
    digest = Digest::SHA256.hexdigest(params.fetch(:endpoint))
    subscription = nil
    attempts = 0

    begin
      PushSubscription.transaction do
        user.lock!
        subscription = PushSubscription.lock.find_by(endpoint_digest: digest, revoked_at: nil)
        if subscription && subscription.user_id != user.id
          subscription.revoke!
          subscription = nil
        end
        subscription ||= session.push_subscriptions.build(endpoint_digest: digest)
        subscription.session = session

        if subscription.new_record? && user.push_subscriptions.active.count >= ACTIVE_COUNT_MAX
          user.push_subscriptions.active.order(last_seen_at: :asc, id: :asc).first.revoke!
        end
        subscription.assign_attributes(
          endpoint: params.fetch(:endpoint),
          p256dh_key: params.fetch(:p256dh_key),
          auth_key: params.fetch(:auth_key),
          expires_at: params[:expires_at],
          name: params[:name].presence,
          user_agent: user_agent.to_s.first(500),
          last_seen_at: Time.current,
          revoked_at: nil,
          failure_count: 0
        )
        subscription.save!
      end
    rescue ActiveRecord::RecordNotUnique
      attempts += 1
      retry if attempts == 1
      raise
    end

    subscription
  end

  def self.revoke!(session:, endpoint: nil, id: nil)
    scope = session.user.push_subscriptions.active
    subscription = if endpoint.present?
      scope.find_by(endpoint_digest: Digest::SHA256.hexdigest(endpoint))
    else
      scope.find_by(id: id)
    end
    subscription&.revoke!
    subscription
  end
end

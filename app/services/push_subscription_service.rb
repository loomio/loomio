class PushSubscriptionService
  ACTIVE_COUNT_MAX = 20

  class << self
    def create_or_update!(session:, params:, user_agent:)
      upsert!(session:, params:, user_agent:, explicit_enable: true, preserve_name: false)
    end

    # Refresh an existing browser subscription after sign-in without undoing a
    # deliberate device removal. Only the explicit enable action clears the
    # user's durable removal marker for this browser endpoint.
    def reconcile!(session:, params:, user_agent:)
      upsert!(session:, params:, user_agent:, explicit_enable: false, preserve_name: true)
    end

    def revoke!(session:, endpoint: nil, id: nil)
      user = session.user
      subscription = nil

      PushSubscription.transaction do
        user.lock!
        scope = user.push_subscriptions.active.lock
        subscription = if endpoint.present?
          scope.find_by!(endpoint_digest: endpoint_digest(endpoint))
        else
          scope.find_by!(id: id)
        end
        record_removal!(user:, endpoint_digest: subscription.endpoint_digest)
        subscription.revoke!
      end

      subscription
    end

    # Logout must durably disable every browser endpoint owned by this session
    # even if client-side unsubscription is delayed or cannot reach the server.
    # Destroy the session while holding the same locks used by enable so logout
    # wins against concurrent subscription creation in another tab.
    def terminate_session!(session:)
      user = session.user

      PushSubscription.transaction do
        user.lock!
        session.lock!
        session.push_subscriptions.active.lock.each do |subscription|
          record_removal!(user:, endpoint_digest: subscription.endpoint_digest)
          subscription.revoke!
        end
        session.destroy!
      end
    end

    private

    # Browser endpoints can survive sessions and account changes. Serialize by
    # user, preserve the endpoint's single active owner, and keep explicit user
    # removals separate from automatic revocation caused by delivery or limits.
    def upsert!(session:, params:, user_agent:, explicit_enable:, preserve_name:)
      raise ActiveRecord::RecordNotFound unless session.persisted?

      user = session.user
      digest = endpoint_digest(params.fetch(:endpoint))
      subscription = nil
      attempts = 0

      begin
        PushSubscription.transaction do
          user.lock!
          session.lock!
          subscription = PushSubscription.lock.find_by(endpoint_digest: digest, revoked_at: nil)

          if explicit_enable
            user.push_subscription_removals.where(endpoint_digest: digest).delete_all
          elsif user.push_subscription_removals.exists?(endpoint_digest: digest)
            subscription&.revoke!
            subscription = nil
            next
          end

          if subscription && subscription.user_id != user.id
            subscription.revoke!
            subscription = nil
          end

          subscription ||= session.push_subscriptions.build(endpoint_digest: digest)
          subscription.session = session

          if subscription.new_record? && user.push_subscriptions.active.count >= ACTIVE_COUNT_MAX
            user.push_subscriptions.active.order(last_seen_at: :asc, id: :asc).first.revoke!
          end

          attributes = {
            endpoint: params.fetch(:endpoint),
            p256dh_key: params.fetch(:p256dh_key),
            auth_key: params.fetch(:auth_key),
            expires_at: params[:expires_at],
            user_agent: user_agent.to_s.first(500),
            last_seen_at: Time.current,
            revoked_at: nil,
            failure_count: 0
          }
          attributes[:name] = params[:name].presence unless preserve_name
          subscription.assign_attributes(attributes)
          subscription.save!
        end
      rescue ActiveRecord::RecordNotUnique
        attempts += 1
        retry if attempts == 1
        raise
      end

      subscription
    end

    def endpoint_digest(endpoint)
      Digest::SHA256.hexdigest(endpoint)
    end

    def record_removal!(user:, endpoint_digest:)
      user.push_subscription_removals.find_or_create_by!(endpoint_digest:)
    end
  end
end

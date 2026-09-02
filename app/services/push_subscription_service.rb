class PushSubscriptionService
  ACTIVE_COUNT_MAX = 20

  class << self
    def create_or_update!(session:, params:, user_agent:)
      update_subscription!(session:, params:, user_agent:, explicit_enable: true)
    end

    # Reconciliation only refreshes push that is already enabled for the current
    # authenticated session. A browser subscription with no matching record is
    # disabled locally and must be enabled again by the user.
    def reconcile!(session:, params:, user_agent:)
      update_subscription!(session:, params:, user_agent:, explicit_enable: false)
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
        subscription.revoke!
      end

      subscription
    end

    private

    # Browser endpoints can survive session rotation. Explicit enable may create
    # or move an endpoint, while background reconciliation can only update the
    # subscription already owned by this exact session.
    def update_subscription!(session:, params:, user_agent:, explicit_enable:)
      raise ActiveRecord::RecordNotFound unless session.persisted?

      user = session.user
      digest = endpoint_digest(params.fetch(:endpoint))
      subscription = nil
      attempts = 0

      begin
        PushSubscription.transaction do
          user.lock!
          session.lock!

          if explicit_enable
            subscription = PushSubscription.lock.find_by(endpoint_digest: digest, revoked_at: nil)
            if subscription && subscription.user_id != user.id
              subscription.revoke!
              subscription = nil
            end
            subscription ||= session.push_subscriptions.build(endpoint_digest: digest)
            subscription.session = session
          else
            subscription = session.push_subscriptions.active.lock.find_by(endpoint_digest: digest)
            unless subscription
              user.push_subscriptions.active.lock.find_by(endpoint_digest: digest)&.revoke!
              next
            end
          end

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
          attributes[:name] = params[:name].presence if explicit_enable
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
  end
end

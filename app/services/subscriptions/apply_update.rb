require "digest"

module Subscriptions
  class ApplyUpdate
    class InvalidUpdate < StandardError; end
    class EventConflict < StandardError; end

    STATE_MAP = {
      "trialing" => "active",
      "active" => "active",
      "past_due" => "past_due",
      "canceling" => "active",
      "canceled" => "canceled",
      "paused" => "on_hold",
      "on_hold" => "on_hold",
      "expired" => "canceled"
    }.freeze
    ENTITLEMENT_KEYS = %w[allow_guests allow_subgroups max_members max_orgs max_threads].freeze

    def self.call(payload:, raw_body:)
      new(payload, raw_body).call
    end

    def initialize(payload, raw_body)
      @payload = payload
      @payload_digest = Digest::SHA256.hexdigest(raw_body)
      @event_id = payload.fetch("event_id")
      raise InvalidUpdate unless payload["type"] == "subscription.updated" && @event_id.present?
    end

    # The receipt and local entitlement projection change atomically. Repeated
    # delivery of the same event is successful without applying it twice.
    def call
      existing = SubscriptionUpdateReceipt.find_by(event_id: @event_id)
      return existing.subscription if existing && existing.payload_digest == @payload_digest
      raise EventConflict if existing

      Subscription.transaction do
        validate_installation!
        target = @payload.fetch("target")
        raise InvalidUpdate unless target.fetch("kind") == "group"

        group = Group.parents_only.find_by!(key: target.fetch("group_id"))
        group.lock!
        subscription = Subscription.for(group)
        raise InvalidUpdate if subscription.chargify_subscription_id.present? || subscription.payment_method == "chargify"

        receipt = SubscriptionUpdateReceipt.create!(event_id: @event_id, payload_digest: @payload_digest)
        subscription.update!(subscription_attributes(subscription))
        receipt.update!(subscription: subscription, processed_at: Time.current)
        subscription
      end
    rescue KeyError, TypeError, ArgumentError
      raise InvalidUpdate
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    private

    def validate_installation!
      expected = Identity.installation_id
      raise InvalidUpdate if expected.blank? || @payload["installation_id"] != expected
    end

    def subscription_attributes(subscription)
      remote = @payload.fetch("subscription")
      product = remote.fetch("product")
      price_point = remote.fetch("price_point")
      entitlements = normalized_entitlements(price_point.fetch("entitlements"))
      state = STATE_MAP.fetch(remote.fetch("state"))
      occurred_at = Time.iso8601(@payload.fetch("occurred_at"))

      {
        billing_service_subscription_id: remote.fetch("id"),
        billing_service_product_id: product.fetch("id"),
        billing_service_price_point_id: price_point.fetch("id"),
        billing_service_updated_at: occurred_at,
        plan: product.fetch("code"),
        state: state,
        payment_method: "loomio_subscriptions",
        renewed_at: parse_time(remote["current_period_started_at"]),
        renews_at: parse_time(remote["next_billing_at"]),
        expires_at: parse_time(remote["expires_at"]),
        canceled_at: parse_time(remote["canceled_at"]),
        activated_at: state == "active" ? (subscription.activated_at || occurred_at) : subscription.activated_at,
        info: (subscription.info || {}).merge(
          "billing_service_product_name" => product.fetch("name"),
          "billing_service_price_point_name" => price_point.fetch("name"),
          "billing_service_currency" => remote.fetch("currency"),
          "billing_service_recurring_amount_cents" => Integer(remote.fetch("recurring_amount_cents")),
          "billing_service_interval_count" => Integer(remote.fetch("interval_count")),
          "billing_service_interval_unit" => remote.fetch("interval_unit")
        )
      }.merge(entitlements)
    end

    def normalized_entitlements(entitlements)
      raise InvalidUpdate unless entitlements.is_a?(Hash)
      raise InvalidUpdate unless entitlements.keys.sort == ENTITLEMENT_KEYS.sort

      entitlements.to_h do |key, value|
        normalized = if key.start_with?("allow_")
          raise InvalidUpdate unless value.in?([ true, false ])
          value
        else
          value.nil? ? nil : Integer(value)
        end
        [ key, normalized ]
      end.symbolize_keys
    end

    def parse_time(value)
      Time.iso8601(value) if value.present?
    end
  end
end

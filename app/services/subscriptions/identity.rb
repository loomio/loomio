require "base64"
require "openssl"

module Subscriptions
  class Identity
    DEFAULT_SERVICE_URL = "https://subscriptions.loomio.com"

    class << self
      def service_url
        ENV.fetch("LOOMIO_SUBSCRIPTIONS_URL", DEFAULT_SERVICE_URL)
      end

      def installation_id
        ENV["LOOMIO_INSTALLATION_ID"].presence || "loomio_#{derive("installation-id").first(32)}"
      end

      def integration_secret
        derive("integration-secret")
      end

      def api_token
        ENV["LOOMIO_SUBSCRIPTIONS_API_TOKEN"].presence || "#{installation_id}.#{integration_secret}"
      end

      def webhook_secret
        ENV["LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET"].presence || integration_secret
      end

      def canonical_origin
        scheme = Rails.env.production? || ENV["FORCE_SSL"].present? ? "https" : "http"
        port = ENV["CANONICAL_PORT"].presence
        "#{scheme}://#{ENV.fetch("CANONICAL_HOST")}#{port ? ":#{port}" : ""}"
      end

      def registration_proof(challenge)
        message = [ "loomio-subscriptions-registration", "v1", installation_id, challenge ].join("\n")
        Base64.urlsafe_encode64(
          OpenSSL::HMAC.digest("SHA256", integration_secret, message),
          padding: false
        )
      end

      private

      def derive(purpose)
        Base64.urlsafe_encode64(
          OpenSSL::HMAC.digest("SHA256", Rails.application.secret_key_base, "loomio-subscriptions:v1:#{purpose}"),
          padding: false
        )
      end
    end
  end
end

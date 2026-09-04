require "json"
require "net/http"
require "uri"

module Subscriptions
  class Registration
    class Error < StandardError; end

    def initialize(base_url: Identity.service_url)
      @base_url = URI.parse(base_url.to_s)
      valid_scheme = @base_url.is_a?(URI::HTTPS) || (!Rails.env.production? && @base_url.is_a?(URI::HTTP))
      valid_origin = valid_scheme && @base_url.host.present? && @base_url.userinfo.nil? &&
        @base_url.path.to_s.in?([ "", "/" ]) && @base_url.query.nil? && @base_url.fragment.nil?
      raise Error, "subscription service URL must be an HTTPS origin" unless valid_origin
    rescue URI::InvalidURIError => error
      raise Error, error.message
    end

    def register!
      return true if ENV["LOOMIO_SUBSCRIPTIONS_API_TOKEN"].present?

      response = post_registration
      body = JSON.parse(response.body)
      raise Error, "subscription service rejected registration" unless response.is_a?(Net::HTTPSuccess)
      raise Error, "subscription service did not activate this installation" unless body.fetch("status") == "active"

      true
    rescue JSON::ParserError, KeyError, SocketError, Timeout::Error, URI::InvalidURIError => error
      raise Error, error.message
    end

    private

    def post_registration
      uri = URI.join(@base_url, "/api/v1/loomio_host_registrations")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request.body = JSON.generate(
        installation_id: Identity.installation_id,
        name: ENV["SITE_NAME"].presence || ENV["CANONICAL_HOST"],
        base_url: Identity.canonical_origin,
        registration_secret: Identity.integration_secret
      )
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
        http.request(request)
      end
    end
  end
end

require "json"
require "net/http"
require "uri"

module Subscriptions
  class Client
    class Error < StandardError; end

    def initialize(base_url: Identity.service_url, api_token: Identity.api_token)
      @base_url = URI.parse(base_url.to_s)
      @api_token = api_token
      validate_configuration!
    end

    def create_session(group:, user:, callback_url:, return_url:)
      uri = URI.join(normalized_base_url, "/api/v1/sessions")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_token}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(
        session: {
          target: { kind: "group", group_id: group.key },
          organization: { id: group.key, name: group.name },
          user: { id: user.id.to_s, name: user.name, email: user.email },
          callback_url: callback_url,
          return_url: return_url
        }
      )
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
        open_timeout: 10, read_timeout: 20) { |http| http.request(request) }
      raise Error, "subscription service returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      url = JSON.parse(response.body).fetch("url")
      raise Error, "subscription service returned an invalid redirect URL" unless service_url?(url)

      url
    rescue JSON::ParserError, KeyError, SocketError, Timeout::Error, URI::InvalidURIError => error
      raise Error, error.message
    end

    private

    def validate_configuration!
      valid_scheme = @base_url.is_a?(URI::HTTPS) || (!Rails.env.production? && @base_url.is_a?(URI::HTTP))
      raise Error, "LOOMIO_SUBSCRIPTIONS_URL must be an HTTPS origin" unless valid_scheme &&
        @base_url.host.present? && @base_url.userinfo.nil? && @base_url.path.to_s.in?([ "", "/" ]) &&
        @base_url.query.nil? && @base_url.fragment.nil?
      raise Error, "LOOMIO_SUBSCRIPTIONS_API_TOKEN is not configured" if @api_token.blank?
    end

    def normalized_base_url
      value = @base_url.to_s
      value.end_with?("/") ? value : "#{value}/"
    end

    def service_url?(value)
      candidate = URI.parse(value)
      candidate.scheme == @base_url.scheme && candidate.host == @base_url.host &&
        candidate.port == @base_url.port && candidate.userinfo.nil?
    rescue URI::InvalidURIError
      false
    end
  end
end

require "base64"
require "net/http"

class Mobile::RelayService
  class Error < StandardError; end

  class << self
    def deliver!(registration:, event_id:, kind:)
      response = request(
        registration: registration,
        method: :post,
        path: "/v1/registrations/#{registration.registration_id}/events",
        body: JSON.generate(event_id: event_id, kind: kind)
      )
      return true if response.code.to_i == 202

      if [ 404, 410 ].include?(response.code.to_i)
        registration.destroy!
        return false
      end
      raise Error, "relay returned HTTP #{response.code}"
    end

    def delete!(registration:)
      response = request(
        registration: registration,
        method: :delete,
        path: "/v1/registrations/#{registration.registration_id}",
        body: "{}"
      )
      return true if [ 200, 404 ].include?(response.code.to_i)

      raise Error, "relay returned HTTP #{response.code}"
    end

    def send_test!(registration:)
      delivered = deliver!(registration: registration, event_id: SecureRandom.uuid, kind: "test")
      raise Error, "relay registration is unavailable" unless delivered

      true
    end

    def event_id_for(notification_delivery_id)
      bytes = Digest::SHA256.digest("loomio-mobile-push-event-v1\0#{Integer(notification_delivery_id)}").bytes.first(16)
      bytes[6] = (bytes[6] & 0x0f) | 0x50
      bytes[8] = (bytes[8] & 0x3f) | 0x80
      hex = bytes.pack("C*").unpack1("H*")
      "#{hex[0, 8]}-#{hex[8, 4]}-#{hex[12, 4]}-#{hex[16, 4]}-#{hex[20, 12]}"
    end

    private

    def request(registration:, method:, path:, body:)
      base = URI.parse(ENV.fetch("PUSH_RELAY_URL"))
      valid_base = base.is_a?(URI::HTTPS) && base.host.present? && base.userinfo.nil? &&
        [ "", "/" ].include?(base.path) && base.query.nil? && base.fragment.nil?
      raise Error, "invalid relay URL" unless valid_base

      uri = URI.join("#{base.to_s.chomp("/")}/", path.delete_prefix("/"))
      timestamp = Time.current.to_i.to_s
      nonce = SecureRandom.urlsafe_base64(24, false)
      canonical = [ method.to_s.upcase, path, timestamp, nonce, Digest::SHA256.hexdigest(body) ].join("\n")
      signature = Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest("SHA256", registration.delivery_key, canonical),
        padding: false
      )
      request_class = { post: Net::HTTP::Post, delete: Net::HTTP::Delete }.fetch(method)
      http_request = request_class.new(uri)
      http_request["Accept"] = "application/json"
      http_request["Content-Type"] = "application/json"
      http_request["X-Loomio-Timestamp"] = timestamp
      http_request["X-Loomio-Nonce"] = nonce
      http_request["X-Loomio-Signature"] = signature
      http_request.body = body

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10
      http.start { |connection| connection.request(http_request) }
    rescue URI::InvalidURIError, KeyError, SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => error
      raise Error, error.message
    end
  end
end

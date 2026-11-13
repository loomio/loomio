require "uri"
require "ipaddr"
require "socket"
require "net/http"
require "json"
require "timeout"
require_relative "error"

module PushRelay
  class HostVerifier
    BLOCKED = %w[
      0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16
      172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.88.99.0/24 192.168.0.0/16
      198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/4 240.0.0.0/4
      ::/96 100::/64 fc00::/7 fe80::/10 ff00::/8 64:ff9b::/96 64:ff9b:1::/48
      2001::/32 2001:db8::/32 2002::/16 3fff::/20
    ].map { |cidr| IPAddr.new(cidr) }.freeze

    def initialize(allow_private_hosts: false, resolver: nil, http_factory: nil)
      @allow_private_hosts = allow_private_hosts
      @resolver = resolver || ->(host) { Addrinfo.getaddrinfo(host, nil, Socket::AF_UNSPEC, Socket::SOCK_STREAM).map(&:ip_address).uniq }
      # Disable environment proxies: the validated destination must be the TLS peer.
      @http_factory = http_factory || ->(host, port) { Net::HTTP.new(host, port, nil) }
    end

    def self.normalized_origin(input)
      raise Error.new(400, "invalid_request") unless input.is_a?(String)
      uri = URI.parse(input)
      unless uri.is_a?(URI::HTTPS) && uri.host && uri.userinfo.nil? &&
          ["", "/"].include?(uri.path) && uri.query.nil? && uri.fragment.nil? && uri.port.between?(1, 65_535)
        raise Error.new(400, "invalid_request")
      end
      "https://#{uri.host.downcase}#{uri.port == 443 ? '' : ":#{uri.port}"}"
    rescue URI::InvalidURIError, URI::InvalidComponentError
      raise Error.new(400, "invalid_request")
    end

    def self.private_address?(address)
      return true if address.include?("/") || address.include?("%")
      ip = IPAddr.new(address).native
      BLOCKED.any? { |network| network.include?(ip) }
    rescue IPAddr::InvalidAddressError
      true
    end

    # Validate every answer, then pin one address while keeping the original TLS
    # hostname for SNI and certificate verification. Never follow redirects.
    def verify(origin, authorization)
      uri = URI.parse(self.class.normalized_origin(origin))
      addresses = Timeout.timeout(8) { @resolver.call(uri.hostname) }
      raise Error.new(502, "upstream_unavailable") if addresses.empty? ||
        (!@allow_private_hosts && addresses.any? { |address| self.class.private_address?(address) })
      http = @http_factory.call(uri.hostname, uri.port)
      http.ipaddr = addresses.first
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.open_timeout = 5
      http.read_timeout = 8
      http.write_timeout = 5
      http.max_retries = 0
      request = Net::HTTP::Post.new("/api/v1/mobile/relay-authorizations/verify")
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(authorization: authorization)
      result = nil
      http.start do |connection|
        connection.request(request) do |response|
          unless response.code == "200" && !response["location"] &&
              response["content-type"].to_s.split(";", 2).first.to_s.strip.downcase == "application/json"
            raise Error.new(502, "upstream_unavailable")
          end
          body = +""
          response.read_body do |chunk|
            body << chunk
            raise Error.new(502, "upstream_unavailable") if body.bytesize > 16_384
          end
          result = JSON.parse(body)
        end
      end
      result
    rescue Error
      raise
    rescue StandardError
      raise Error.new(502, "upstream_unavailable")
    end
  end
end

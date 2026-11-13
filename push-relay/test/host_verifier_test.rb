require_relative "test_helper"

class HostVerifierTest < Minitest::Test
  class Response
    attr_accessor :code, :headers, :chunks
    def initialize
      @code, @headers, @chunks = "200", { "content-type" => "application/json" }, ['{"registration_id":"id","delivery_key":"key"}']
    end
    def [](name) = @headers[name]
    def read_body(&block) = @chunks.each(&block)
  end

  class HTTP
    attr_accessor :ipaddr, :use_ssl, :verify_mode, :open_timeout, :read_timeout, :write_timeout, :max_retries
    attr_reader :requests
    def initialize(response)
      @response, @requests = response, []
    end
    def start = yield self
    def request(request)
      @requests << request
      yield @response
    end
  end

  def setup
    @response = Response.new
    @http = HTTP.new(@response)
    @addresses, @factories = ["8.8.8.8"], []
    @verifier = PushRelay::HostVerifier.new(resolver: ->(_host) { @addresses }, http_factory: ->(host, port) { @factories << [host, port]; @http })
  end

  def test_normalizes_origins_without_accepting_other_authority_or_path_data
    assert_equal "https://community.example:8443", PushRelay::HostVerifier.normalized_origin("https://Community.Example:8443/")
    %w[http://example.com https://user@example.com https://example.com/path https://example.com/?q=1 https://example.com/#fragment].each do |origin|
      assert_raises(PushRelay::Error) { PushRelay::HostVerifier.normalized_origin(origin) }
    end
  end

  def test_blocks_private_reserved_mapped_and_documentation_addresses
    %w[127.0.0.1 10.1.2.3 100.64.0.1 169.254.169.254 192.0.2.1 198.18.0.1 198.51.100.1 203.0.113.1
      ::1 fd00::1 ::ffff:127.0.0.1 ::ffff:7f00:1 ::192.168.1.1 2001:db8::1 3fff::1 bad 8.8.8.8/24].each do |ip|
      assert PushRelay::HostVerifier.private_address?(ip), ip
    end
    refute PushRelay::HostVerifier.private_address?("8.8.8.8")
    refute PushRelay::HostVerifier.private_address?("2606:4700:4700::1111")
  end

  def test_rejects_entire_dns_answer_set_before_connecting
    [[], ["127.0.0.1"], ["8.8.8.8", "169.254.169.254"]].each do |addresses|
      @addresses = addresses
      assert_raises(PushRelay::Error) { @verifier.verify("https://community.example", "token") }
    end
    assert_empty @factories
  end

  def test_pins_validated_address_and_preserves_tls_hostname
    result = @verifier.verify("https://community.example:8443", "authorization-token")
    assert_equal [["community.example", 8443]], @factories
    assert_equal "8.8.8.8", @http.ipaddr
    assert @http.use_ssl
    assert_equal OpenSSL::SSL::VERIFY_PEER, @http.verify_mode
    assert_equal 0, @http.max_retries
    assert_equal "/api/v1/mobile/relay-authorizations/verify", @http.requests.first.path
    assert_equal({ "authorization" => "authorization-token" }, JSON.parse(@http.requests.first.body))
    assert_equal "id", result.fetch("registration_id")
  end

  def test_rejects_redirects_wrong_media_types_invalid_json_and_oversized_responses
    @response.code = "302"
    assert_raises(PushRelay::Error) { @verifier.verify("https://example.com", "token") }
    @response.code = "200"
    @response.headers["location"] = "https://elsewhere.example"
    assert_raises(PushRelay::Error) { @verifier.verify("https://example.com", "token") }
    @response.headers.delete("location")
    @response.headers["content-type"] = "text/html"
    assert_raises(PushRelay::Error) { @verifier.verify("https://example.com", "token") }
    @response.headers["content-type"] = "application/json"
    @response.chunks = ["bad JSON"]
    assert_raises(PushRelay::Error) { @verifier.verify("https://example.com", "token") }
    @response.chunks = ["x" * 16_384, "x"]
    assert_raises(PushRelay::Error) { @verifier.verify("https://example.com", "token") }
  end
end

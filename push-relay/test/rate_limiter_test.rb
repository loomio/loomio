require_relative "test_helper"

class RateLimiterTest < Minitest::Test
  def setup
    @time = 0.0
  end

  def limiter(**options)
    PushRelay::RateLimiter.new(clock: -> { @time }, **options)
  end

  def env(address = "192.0.2.1", forwarded = nil)
    { "REMOTE_ADDR" => address, "HTTP_X_FORWARDED_FOR" => forwarded }
  end

  def test_bursts_refill_and_budgets_are_separate
    limit = limiter
    11.times { assert_nil limit.retry_after(env, :registrations) }
    assert_equal 2, limit.retry_after(env, :registrations)
    51.times { assert_nil limit.retry_after(env, :deliveries) }
    assert_equal 1, limit.retry_after(env, :deliveries)
    @time = 0.2
    assert_nil limit.retry_after(env, :deliveries)
    @time = 2
    assert_nil limit.retry_after(env, :registrations)
    assert_equal 2, limit.retry_after(env, :registrations)
  end

  def test_ignores_spoofed_headers_and_stops_at_nearest_untrusted_hop
    limit = limiter(trusted_proxy_cidr: "172.18.0.0/16")
    11.times do |index|
      assert_nil limit.retry_after(env("192.0.2.1", "198.51.100.#{index}"), :registrations)
    end
    assert_equal 2, limit.retry_after(env("::ffff:172.18.0.2", "198.51.100.9, 192.0.2.1, 172.18.0.3"), :registrations)
    assert_nil limit.retry_after(env("172.18.0.2", "192.0.2.2"), :registrations)
  end

  def test_malformed_forwarding_falls_back_to_peer
    limit = limiter(trusted_proxy_cidr: "172.18.0.0/16")
    11.times { |i| assert_nil limit.retry_after(env("172.18.0.2", "bad-#{i}"), :registrations) }
    assert_equal 2, limit.retry_after(env("172.18.0.2", ""), :registrations)
  end

  def test_normalizes_ipv6_and_ipv4_mapped_spellings
    limit = limiter(trusted_proxy_cidr: "fd00::/64")
    11.times do
      assert_nil limit.retry_after(env("fd00::1", "2001:0db8:0000::1"), :registrations)
      assert_nil limit.retry_after(env("fd00::1", "::ffff:c000:201"), :registrations)
    end
    assert_equal 2, limit.retry_after(env("fd00::1", "2001:db8::1"), :registrations)
    assert_equal 2, limit.retry_after(env("fd00::1", "192.0.2.1"), :registrations)
    assert_equal 2, limit.retry_after(env("::ffff:192.0.2.1"), :registrations)
  end

  def test_bounds_memory_without_evicting_active_clients
    limit = limiter(entries_max: 2)
    11.times { assert_nil limit.retry_after(env, :registrations) }
    assert_nil limit.retry_after(env("192.0.2.2"), :registrations)
    assert_equal 60, limit.retry_after(env("192.0.2.3"), :registrations)
    assert_equal 2, limit.retry_after(env, :registrations)
    @time = 59
    assert_nil limit.retry_after(env, :registrations)
    @time = 60
    assert_nil limit.retry_after(env("192.0.2.3"), :registrations)
    assert_equal 60, limit.retry_after(env("192.0.2.4"), :registrations)
  end

  def test_rejects_invalid_trust_networks
    %w[172.18.0.0 172.18.0.0/33 fd00::/129 example.com/24 172.18.0.0/-1 172.18.0.0/16/8].each do |cidr|
      assert_raises(ArgumentError, cidr) { limiter(trusted_proxy_cidr: cidr) }
    end
  end
end

class RateLimiterTest
  def test_cloudflare_client_header_requires_a_verified_nearest_edge
    limit = limiter(trusted_proxy_cidr: "172.18.0.0/16", trusted_edge_cidrs: ["173.245.48.0/20"])
    11.times do |i|
      request = env("172.18.0.2", "198.51.100.#{i}, 192.0.2.1, 173.245.48.5").merge("HTTP_CF_CONNECTING_IP" => "192.0.2.1")
      assert_nil limit.retry_after(request, :registrations)
    end
    request = env("172.18.0.2", "173.245.48.6").merge("HTTP_CF_CONNECTING_IP" => "192.0.2.1")
    assert_equal 2, limit.retry_after(request, :registrations)
    assert_nil limit.retry_after(request.merge("HTTP_CF_CONNECTING_IP" => "192.0.2.2"), :registrations)
    assert_equal 2, limit.retry_after(env("192.0.2.1").merge("HTTP_CF_CONNECTING_IP" => "192.0.2.9"), :registrations)
    assert_equal 2, limit.retry_after(env("172.18.0.2", "173.245.48.5, 192.0.2.1").merge("HTTP_CF_CONNECTING_IP" => "192.0.2.9"), :registrations)
  end

  def test_cloudflare_malformed_header_falls_back_to_edge_bucket
    limit = limiter(trusted_proxy_cidr: "172.18.0.0/16", trusted_edge_cidrs: ["173.245.48.0/20"])
    11.times do |i|
      assert_nil limit.retry_after(env("172.18.0.2", "173.245.48.5").merge("HTTP_CF_CONNECTING_IP" => "bad-#{i}"), :registrations)
    end
    assert_equal 2, limit.retry_after(env("172.18.0.2", "173.245.48.5"), :registrations)
    assert_raises(ArgumentError) { limiter(trusted_edge_cidrs: ["invalid"]) }
  end
end

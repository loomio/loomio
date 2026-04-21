require 'test_helper'
require 'minitest/mock'

class LinkPreviewServiceTest < ActiveSupport::TestCase
  # Avoid hitting real DNS by stubbing Resolv.getaddresses for each test.
  def with_dns(map)
    Resolv.stub(:getaddresses, ->(host) { map.fetch(host, []) }) do
      yield
    end
  end

  test "safe_to_fetch? rejects non-http schemes" do
    with_dns('example.com' => ['93.184.216.34']) do
      refute LinkPreviewService.safe_to_fetch?('file:///etc/passwd')
      refute LinkPreviewService.safe_to_fetch?('gopher://example.com/')
      refute LinkPreviewService.safe_to_fetch?('ftp://example.com/')
      refute LinkPreviewService.safe_to_fetch?('javascript:alert(1)')
    end
  end

  test "safe_to_fetch? rejects private and loopback IP literals" do
    refute LinkPreviewService.safe_to_fetch?('http://127.0.0.1/')
    refute LinkPreviewService.safe_to_fetch?('http://10.0.0.1/')
    refute LinkPreviewService.safe_to_fetch?('http://192.168.1.1/')
    refute LinkPreviewService.safe_to_fetch?('http://169.254.169.254/latest/meta-data/')
    refute LinkPreviewService.safe_to_fetch?('http://[::1]/')
  end

  test "safe_to_fetch? rejects hostnames that resolve to blocked ranges" do
    with_dns(
      'metadata.attacker.test' => ['169.254.169.254'],
      'redis.attacker.test'    => ['127.0.0.1'],
      'lan.attacker.test'      => ['10.0.0.5']
    ) do
      refute LinkPreviewService.safe_to_fetch?('http://metadata.attacker.test/')
      refute LinkPreviewService.safe_to_fetch?('http://redis.attacker.test:6379/')
      refute LinkPreviewService.safe_to_fetch?('http://lan.attacker.test/')
    end
  end

  test "safe_to_fetch? rejects multi-A-record where any IP is private" do
    with_dns('mixed.test' => ['93.184.216.34', '10.0.0.1']) do
      refute LinkPreviewService.safe_to_fetch?('http://mixed.test/')
    end
  end

  test "safe_to_fetch? rejects when host cannot be resolved" do
    with_dns('nope.test' => []) do
      refute LinkPreviewService.safe_to_fetch?('http://nope.test/')
    end
  end

  test "safe_to_fetch? accepts a public hostname" do
    with_dns('example.com' => ['93.184.216.34']) do
      assert LinkPreviewService.safe_to_fetch?('https://example.com/page')
    end
  end

  test "fetch short-circuits on unsafe URL without making a request" do
    # If HTTParty.get were called, WebMock would raise (net connect disallowed).
    assert_nil LinkPreviewService.fetch('http://169.254.169.254/latest/meta-data/')
  end

  test "fetch does not follow redirect to a private IP" do
    with_dns(
      'public.test'  => ['93.184.216.34'],
      'private.test' => ['169.254.169.254']
    ) do
      WebMock.stub_request(:get, 'http://public.test/').
        to_return(status: 302, headers: { 'Location' => 'http://private.test/' })
      assert_nil LinkPreviewService.fetch('http://public.test/')
    end
  end

  test "fetch gives up after MAX_REDIRECTS hops" do
    with_dns('a.test' => ['93.184.216.34'], 'b.test' => ['93.184.216.34']) do
      WebMock.stub_request(:get, 'http://a.test/').
        to_return(status: 302, headers: { 'Location' => 'http://b.test/' })
      WebMock.stub_request(:get, 'http://b.test/').
        to_return(status: 302, headers: { 'Location' => 'http://a.test/' })
      assert_nil LinkPreviewService.fetch('http://a.test/')
    end
  end
end

require 'test_helper'

class SafeHttpServiceTest < ActiveSupport::TestCase
  # Avoid hitting real DNS by stubbing Resolv.getaddresses for each test.
  def with_dns(map)
    Resolv.stub(:getaddresses, ->(host) { map.fetch(host, []) }) do
      yield
    end
  end

  test "safe_to_fetch? rejects non-http schemes" do
    with_dns('example.com' => ['93.184.216.34']) do
      refute SafeHttpService.safe_to_fetch?('file:///etc/passwd')
      refute SafeHttpService.safe_to_fetch?('gopher://example.com/')
      refute SafeHttpService.safe_to_fetch?('ftp://example.com/')
      refute SafeHttpService.safe_to_fetch?('javascript:alert(1)')
    end
  end

  test "safe_to_fetch? rejects private and loopback IP literals" do
    refute SafeHttpService.safe_to_fetch?('http://127.0.0.1/')
    refute SafeHttpService.safe_to_fetch?('http://10.0.0.1/')
    refute SafeHttpService.safe_to_fetch?('http://192.168.1.1/')
    refute SafeHttpService.safe_to_fetch?('http://169.254.169.254/latest/meta-data/')
    refute SafeHttpService.safe_to_fetch?('http://[::1]/')
  end

  test "safe_to_fetch? rejects hostnames that resolve to blocked ranges" do
    with_dns(
      'metadata.attacker.test' => ['169.254.169.254'],
      'redis.attacker.test'    => ['127.0.0.1'],
      'lan.attacker.test'      => ['10.0.0.5']
    ) do
      refute SafeHttpService.safe_to_fetch?('http://metadata.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://redis.attacker.test:6379/')
      refute SafeHttpService.safe_to_fetch?('http://lan.attacker.test/')
    end
  end

  test "safe_to_fetch? rejects IPv6 transition addresses" do
    with_dns(
      'compatible.attacker.test'  => ['::10.0.0.1'],
      'nat64.attacker.test'       => ['64:ff9b::10.0.0.1'],
      'nat64-local.attacker.test' => ['64:ff9b:1::a00:1'],
      'teredo.attacker.test'      => ['2001:0:4136:e378:8000:63bf:f5ff:fffe'],
      'six-to-four.attacker.test' => ['2002:0a00:0001::']
    ) do
      refute SafeHttpService.safe_to_fetch?('http://compatible.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://nat64.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://nat64-local.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://teredo.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://six-to-four.attacker.test/')
    end
  end

  test "safe_to_fetch? rejects IPv4-mapped private addresses" do
    with_dns(
      'loopback-mapped.attacker.test' => ['::ffff:127.0.0.1'],
      'metadata-mapped.attacker.test' => ['::ffff:169.254.169.254'],
      'private-mapped.attacker.test'  => ['::ffff:10.0.0.1']
    ) do
      refute SafeHttpService.safe_to_fetch?('http://loopback-mapped.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://metadata-mapped.attacker.test/')
      refute SafeHttpService.safe_to_fetch?('http://private-mapped.attacker.test/')
    end
  end

  test "safe_to_fetch? accepts an IPv4-mapped public address" do
    with_dns('public-mapped.test' => ['::ffff:93.184.216.34']) do
      assert SafeHttpService.safe_to_fetch?('https://public-mapped.test/')
    end
  end

  test "safe_to_fetch? accepts a public IPv6 address outside transition ranges" do
    with_dns('public-ipv6.test' => ['2001:4860:4860::8888']) do
      assert SafeHttpService.safe_to_fetch?('https://public-ipv6.test/')
    end
  end

  test "safe_to_fetch? rejects multi-A-record where any IP is private" do
    with_dns('mixed.test' => ['93.184.216.34', '10.0.0.1']) do
      refute SafeHttpService.safe_to_fetch?('http://mixed.test/')
    end
  end

  test "safe_to_fetch? rejects when host cannot be resolved" do
    with_dns('nope.test' => []) do
      refute SafeHttpService.safe_to_fetch?('http://nope.test/')
    end
  end

  test "safe_to_fetch? accepts a public hostname" do
    with_dns('example.com' => ['93.184.216.34']) do
      assert SafeHttpService.safe_to_fetch?('https://example.com/page')
    end
  end

  test "fetch short-circuits on unsafe URL without making a request" do
    # If an HTTP request were made, WebMock would raise (net connect disallowed).
    assert_nil SafeHttpService.fetch('http://169.254.169.254/latest/meta-data/')
  end

  test "fetch does not follow redirect to a private IP" do
    with_dns(
      'public.test'  => ['93.184.216.34'],
      'private.test' => ['169.254.169.254']
    ) do
      WebMock.stub_request(:get, 'http://public.test/').
        to_return(status: 302, headers: { 'Location' => 'http://private.test/' })
      assert_nil SafeHttpService.fetch('http://public.test/')
    end
  end

  test "fetch gives up after MAX_REDIRECTS hops" do
    with_dns('a.test' => ['93.184.216.34'], 'b.test' => ['93.184.216.34']) do
      WebMock.stub_request(:get, 'http://a.test/').
        to_return(status: 302, headers: { 'Location' => 'http://b.test/' })
      WebMock.stub_request(:get, 'http://b.test/').
        to_return(status: 302, headers: { 'Location' => 'http://a.test/' })
      assert_nil SafeHttpService.fetch('http://a.test/')
    end
  end

  test "fetch returns link preview metadata as plain text" do
    with_dns('preview.test' => ['93.184.216.34']) do
      WebMock.stub_request(:get, 'http://preview.test/').to_return(
        status: 200,
        body: <<~HTML
          <html>
            <head>
              <meta property="og:title" content="&lt;img src=x onerror=alert(1)&gt;Quarterly update">
              <meta property="og:description" content="Fish &amp; Chips — 2 &lt; 3; read &lt;strong&gt;the report&lt;/strong&gt;">
            </head>
          </html>
        HTML
      )

      preview = SafeHttpService.fetch('http://preview.test/')

      assert_equal 'Quarterly update', preview[:title]
      assert_equal 'Fish & Chips — 2 < 3; read the report', preview[:description]
    end
  end
end

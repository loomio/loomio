require 'ipaddr'
require 'resolv'
require 'net/http'
require 'stringio'

module LinkPreviewService
  MAX_REDIRECTS = 3
  REQUEST_TIMEOUT_SECONDS = 5

  # Any resolved host IP in these ranges short-circuits the fetch. Covers loopback,
  # private networks, link-local (including AWS/GCP metadata at 169.254.169.254),
  # CGN, IETF/benchmark/multicast reserves, and their IPv6 equivalents.
  BLOCKED_IP_RANGES = [
    IPAddr.new('0.0.0.0/8'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('100.64.0.0/10'),
    IPAddr.new('127.0.0.0/8'),
    IPAddr.new('169.254.0.0/16'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.0.0.0/24'),
    IPAddr.new('192.168.0.0/16'),
    IPAddr.new('198.18.0.0/15'),
    IPAddr.new('224.0.0.0/4'),
    IPAddr.new('240.0.0.0/4'),
    IPAddr.new('255.255.255.255/32'),
    IPAddr.new('::/128'),
    IPAddr.new('::1/128'),
    IPAddr.new('fc00::/7'),
    IPAddr.new('fe80::/10'),
    IPAddr.new('ff00::/8')
  ].freeze

  def self.fetch(url, redirect_depth: 0)
    response = pinned_get(url)
    return nil unless response

    if [301, 302, 303, 307, 308].include?(response.code.to_i) && response['location']
      return nil if redirect_depth >= MAX_REDIRECTS
      next_url = URI.join(url, response['location']).to_s
      return fetch(next_url, redirect_depth: redirect_depth + 1)
    end
    return nil if response.code.to_i != 200
    doc = Nokogiri::HTML::Document.parse(response.body)

    title = [doc.css('meta[property="og:title"]').attr('content')&.text,
             doc.css('title').first&.text,
             doc.css('h1').first&.text].reject(&:blank?).first

    bad_titles = [/Google \w+: Sign-in/]

    return nil if title.blank?
    return nil if bad_titles.any? {|bt| bt.match?(title) }

    description = [doc.css('meta[property="og:description"]').attr('content')&.text,
                   doc.css('meta[name="description"]').attr('content')&.text].reject(&:blank?).first

    image = [doc.css('meta[property="og:image"]').attr('content')&.text,
             doc.css('meta[name="og:image"]').attr('content')&.text,
             doc.css('img[itemprop="image"]').attr('src')&.text,
             doc.css('link[rel="image_src"]').attr('href')&.text].reject(&:blank?).first

    {title: String(title).truncate(240),
     description: String(description).truncate(240),
     image: image,
     url: url,
     fit: 'contain',
     align: 'center',
     hostname: URI(url).host}
  end

  def self.fetch_urls(urls)
    previews = []
    threads = []
    Array(urls).compact.reject {|u| BlockedDomain.where(name: URI(u).host).exists? }.each do |u|
      # spawn a new thread for each url
      threads << Thread.new do
        previews.push fetch(u)
      end
    end
    threads.each { |t| t.join }
    previews.compact
  rescue SocketError, URI::InvalidURIError, HTTParty::UnsupportedURIScheme, HTTParty::RedirectionTooDeep
    []
  end

  def self.safe_to_fetch?(url)
    uri = URI.parse(url.to_s)
    return false unless %w[http https].include?(uri.scheme)
    return false if uri.host.to_s.empty?
    resolved = Resolv.getaddresses(uri.host)
    return false if resolved.empty?
    resolved.none? { |ip| blocked_ip?(ip) }
  rescue URI::InvalidURIError, Resolv::ResolvError
    false
  end

  # Fetch a URL's raw body as an IO, applying the same SSRF protection as the
  # link-preview fetch (single DNS resolution, IP-range allow-list, connection
  # pinned to the validated address). Returns nil if the URL is unsafe or the
  # request fails. Used for fetching remote avatars/logos.
  def self.safe_open(url, max_bytes: 10.megabytes)
    response = pinned_get(url)
    return nil unless response && response.code.to_i == 200
    body = response.body.to_s
    return nil if body.bytesize > max_bytes

    StringIO.new(body)
  end

  def self.pinned_get(url)
    pinned_request(:get, url)
  end

  # Performs an HTTP request while defeating DNS rebinding: the host is resolved
  # exactly once, every resolved address is checked against BLOCKED_IP_RANGES,
  # and the socket is pinned (via Net::HTTP#ipaddr=) to the address we
  # validated — so Net::HTTP cannot re-resolve to an internal IP between the
  # check and the connection. Redirects are NOT followed (callers that need to
  # follow must re-validate each hop). Returns a Net::HTTPResponse or nil.
  # Use this for ANY outbound request to a user/provider-controlled URL
  # (link previews, chatbot webhooks/Matrix, remote avatars).
  def self.pinned_request(method, url, headers: {}, body: nil, timeout: REQUEST_TIMEOUT_SECONDS)
    uri = URI.parse(url.to_s)
    return nil unless %w[http https].include?(uri.scheme)
    return nil if uri.host.to_s.empty?

    safe_ip = validated_ip(uri.host)
    return nil unless safe_ip

    http = Net::HTTP.new(uri.host, uri.port)
    http.ipaddr = safe_ip
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = timeout
    http.read_timeout = timeout

    request_class = {
      get: Net::HTTP::Get, post: Net::HTTP::Post, put: Net::HTTP::Put
    }.fetch(method.to_sym)
    request = request_class.new(uri)
    headers.each { |k, v| request[k] = v }
    request.body = body if body

    http.start { |h| h.request(request) }
  rescue URI::InvalidURIError, KeyError, SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError, IOError
    nil
  end

  # Resolve host to a single address that is confirmed to be outside the
  # blocked ranges. Rejects the host outright if ANY resolved address is
  # blocked (matching the strict semantics of safe_to_fetch?). Handles literal
  # IP hosts without a DNS lookup.
  def self.validated_ip(host)
    literal = begin
      IPAddr.new(host)
      true
    rescue IPAddr::InvalidAddressError
      false
    end

    ips = literal ? [host] : Resolv.getaddresses(host)
    return nil if ips.empty?
    return nil if ips.any? { |ip| blocked_ip?(ip) }

    ips.first
  rescue Resolv::ResolvError
    nil
  end

  def self.blocked_ip?(ip_str)
    ip = IPAddr.new(ip_str)
    BLOCKED_IP_RANGES.any? { |range| range.include?(ip) }
  rescue IPAddr::InvalidAddressError
    true
  end
end

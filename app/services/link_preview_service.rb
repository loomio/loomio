require 'ipaddr'
require 'resolv'

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
    return nil unless safe_to_fetch?(url)
    response = HTTParty.get(url, follow_redirects: false, timeout: REQUEST_TIMEOUT_SECONDS)
    if [301, 302, 303, 307, 308].include?(response.code) && response.headers['location']
      return nil if redirect_depth >= MAX_REDIRECTS
      next_url = URI.join(url, response.headers['location']).to_s
      return fetch(next_url, redirect_depth: redirect_depth + 1)
    end
    return nil if response.code != 200
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

  def self.blocked_ip?(ip_str)
    ip = IPAddr.new(ip_str)
    BLOCKED_IP_RANGES.any? { |range| range.include?(ip) }
  rescue IPAddr::InvalidAddressError
    true
  end
end

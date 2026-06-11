require 'digest/sha1'
require 'net/http'

class PwnedPasswordService
  RANGE_ENDPOINT = URI('https://api.pwnedpasswords.com/range/').freeze
  OPEN_TIMEOUT = 2
  READ_TIMEOUT = 3

  def self.pwned?(password)
    new(password).pwned?
  end

  def initialize(password)
    @password = password.to_s
  end

  def pwned?
    return false if @password.blank?

    suffixes.include?(sha1.last(35))
  rescue StandardError => error
    Rails.logger.warn("Pwned password check failed: #{error.class}: #{error.message}")
    false
  end

  private

  def suffixes
    response = Net::HTTP.start(endpoint.host, endpoint.port, use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
      http.get(endpoint.request_uri, 'User-Agent' => 'Loomio')
    end

    return [] unless response.is_a?(Net::HTTPSuccess)

    response.body.each_line.map { |line| line.split(':', 2).first }
  end

  def endpoint
    URI.join(RANGE_ENDPOINT.to_s, sha1.first(5))
  end

  def sha1
    @sha1 ||= Digest::SHA1.hexdigest(@password).upcase
  end
end

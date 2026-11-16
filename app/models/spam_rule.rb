require 'ipaddr'

class SpamRule < ApplicationRecord
  include Discard::Model
  has_paper_trail

  KINDS = { 'ip' => 'IP address or network', 'email_domain' => 'Email domain', 'regex' => 'Regex' }.freeze
  REGEX_TIMEOUT = 0.01
  attr_reader :match_error
  has_many :hits, class_name: 'SpamRuleHit', dependent: :delete_all
  scope :active, -> { kept.where('expires_at IS NULL OR expires_at > ?', Time.current) }
  before_validation :normalize_pattern
  validates :kind, inclusion: { in: KINDS.keys }
  validates :pattern, presence: true, length: { maximum: 4096 }
  validate :valid_pattern
  validate do
    errors.add(:expires_at, 'must be a valid date and time') if expires_at_before_type_cast.present? && expires_at.nil?
  end

  def active?
    kept? && (expires_at.nil? || expires_at > Time.current)
  end

  def state
    return 'Disabled' if discarded?
    active? ? 'Active' : 'Expired'
  end

  # Domains apply only to addresses; legacy regex rules retain checks on both
  # account addresses and model text. IPs never match text.
  def matches?(value, target:)
    @match_error = nil
    return false if value.blank?
    case kind
    when 'ip'
      target == :ip && IPAddr.new(pattern).native.include?(IPAddr.new(value).native)
    when 'email_domain'
      target == :email && value.to_s.include?('@') && value.to_s.strip.downcase.split('@').last == pattern
    when 'regex'
      target != :ip && Regexp.new(pattern, Regexp::IGNORECASE, timeout: REGEX_TIMEOUT).match?(value.to_s)
    end
  rescue Regexp::TimeoutError
    @match_error = 'Regex matching timed out; the value is blocked'
    Rails.logger.warn("spam rule #{id} exceeded its regex timeout")
    true
  rescue IPAddr::Error
    false
  end

  private

  def normalize_pattern
    self.pattern = pattern.to_s
    self.pattern = pattern.strip unless kind == 'regex'
    self.pattern = pattern.downcase if kind == 'email_domain'
  end

  def valid_pattern
    return if pattern.blank? || !KINDS.key?(kind)
    case kind
    when 'ip'
      IPAddr.new(pattern)
    when 'email_domain'
      valid = /\A[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?\.[a-z]{2,}\z/.match?(pattern) &&
        !pattern.include?('..') && pattern.split('.').all? { |label| !label.start_with?('-') && !label.end_with?('-') }
      errors.add(:pattern, 'must be a complete domain, without @ or a regular expression') unless valid
    when 'regex'
      Regexp.new(pattern, Regexp::IGNORECASE, timeout: REGEX_TIMEOUT)
    end
  rescue IPAddr::Error, RegexpError => error
    errors.add(:pattern, "is invalid: #{error.message}")
  end
end

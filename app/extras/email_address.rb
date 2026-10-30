module EmailAddress
  # Match Loomio's case-insensitive mailbox identity without applying provider-
  # specific alias rules. Dots and +tags can identify distinct accounts.
  def self.normalize(value)
    value.to_s.strip.downcase
  end
end

# The Server API key authorizes account and membership changes across the
# installation. A short key fails at boot rather than being silently accepted.
module ServerApiKey
  LENGTH_MIN = 17

  # B3_API_KEY is the legacy name, read only when SERVER_API_KEY is unset.
  def self.value
    ENV['SERVER_API_KEY'].presence || ENV['B3_API_KEY'].to_s
  end

  def self.validate!
    key = value
    return if key.empty? || key.length >= LENGTH_MIN

    raise ArgumentError, "SERVER_API_KEY must be at least #{LENGTH_MIN} characters, or unset to disable the Server API"
  end
end

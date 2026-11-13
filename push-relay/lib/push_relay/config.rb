require "base64"
require "openssl"

module PushRelay
  class Config
    attr_reader :database_path, :encryption_key, :apns, :allow_private_hosts, :trusted_proxy_cidr, :trusted_edge_cidrs

    def initialize(env = ENV)
      @database_path = self.class.required(env, "LOOMIO_DATABASE_PATH")
      @encryption_key = Base64.strict_decode64(self.class.required(env, "RELAY_ENCRYPTION_KEY"))
      raise ArgumentError, "RELAY_ENCRYPTION_KEY must encode exactly 32 bytes" unless @encryption_key.bytesize == 32
      team_id = self.class.required(env, "APNS_TEAM_ID")
      raise ArgumentError, "APNS_TEAM_ID must be a 10-character Apple team ID" unless /\A[A-Z0-9]{10}\z/.match?(team_id)
      production = signing_key(env, "APNS_KEY_ID", "APNS_PRIVATE_KEY")
      sandbox_names = %w[APNS_SANDBOX_KEY_ID APNS_SANDBOX_PRIVATE_KEY APNS_SANDBOX_PRIVATE_KEY_FILE]
      sandbox = signing_key(env, sandbox_names[0], sandbox_names[1]) if sandbox_names.any? { |name| !env[name].to_s.strip.empty? }
      @apns = { team_id: team_id, topic: self.class.required(env, "APNS_TOPIC"), production: production, sandbox: sandbox }
      @allow_private_hosts = env.key?("ALLOW_PRIVATE_HOSTS")
      @trusted_proxy_cidr = env["PROXY_TRUSTED_CIDR"].to_s.strip
      @trusted_edge_cidrs = env["LOOMIO_TRUSTED_EDGE_CIDRS"].to_s.split(/[\s,]+/)
    end

    def self.required(env, name)
      value = env[name].to_s.strip
      raise ArgumentError, "#{name} is required" if value.empty?
      value
    end

    private

    def signing_key(env, id_name, key_name)
      id = self.class.required(env, id_name)
      raise ArgumentError, "#{id_name} must be a 10-character Apple key ID" unless /\A[A-Z0-9]{10}\z/.match?(id)
      file = env["#{key_name}_FILE"].to_s.strip
      inline = env[key_name].to_s.strip
      raise ArgumentError, "Set only one of #{key_name} or #{key_name}_FILE" unless file.empty? || inline.empty?
      pem = file.empty? ? self.class.required(env, key_name).gsub('\\n', "\n") : File.read(file).strip
      key = OpenSSL::PKey.read(pem)
      unless key.is_a?(OpenSSL::PKey::EC) && key.private? && key.group.curve_name == "prime256v1"
        raise ArgumentError, "#{key_name} must be a private P-256 EC key"
      end
      { key_id: id, private_key: key }
    rescue OpenSSL::PKey::PKeyError
      raise ArgumentError, "#{key_name} must be a valid private key"
    end
  end
end

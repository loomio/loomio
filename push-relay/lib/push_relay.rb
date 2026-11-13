require_relative "push_relay/config"
require_relative "push_relay/database"
require_relative "push_relay/repository"
require_relative "push_relay/app"

module PushRelay
  def self.build(env = ENV)
    config = Config.new(env)
    database = Database.open(config.database_path)
    repository = Repository.new(database, config.encryption_key)
    app = App.new(repository: repository,
      verifier: HostVerifier.new(allow_private_hosts: config.allow_private_hosts),
      apns: APNSClient.new(config.apns),
      rate_limiter: RateLimiter.new(trusted_proxy_cidr: config.trusted_proxy_cidr, trusted_edge_cidrs: config.trusted_edge_cidrs))
    maintenance = Thread.new do
      loop do
        sleep 3_600
        begin
          repository.cleanup
        rescue StandardError
          $stderr.puts(JSON.generate(event: "relay_cleanup_failed"))
        end
      end
    end
    at_exit do
      maintenance.kill
      maintenance.join
      repository.close
    end
    app
  end
end

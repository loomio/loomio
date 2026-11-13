require "ipaddr"

module PushRelay
  class RateLimiter
    LIMITS = { registrations: [30.0 / 60, 11], deliveries: [300.0 / 60, 51] }.freeze

    def initialize(trusted_proxy_cidr: nil, trusted_edge_cidrs: [], clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }, entries_max: 10_000)
      @trusted = parse_network(trusted_proxy_cidr)
      @trusted_edges = trusted_edge_cidrs.map { |cidr| parse_network(cidr, name: "LOOMIO_TRUSTED_EDGE_CIDRS") }
      @clock, @entries_max = clock, entries_max
      @entries, @mutex = {}, Mutex.new
      @cleanup_at = @clock.call + 60
    end

    def retry_after(env, group)
      address = client_address(env)
      @mutex.synchronize do
        now = @clock.call
        if now >= @cleanup_at
          @entries.delete_if { |_key, entry| now - entry[:updated_at] >= 60 }
          @cleanup_at = now + 60
        end
        key = [group, address]
        rate, capacity = LIMITS.fetch(group)
        entry = @entries[key]
        unless entry
          return [1, (@cleanup_at - now).ceil].max if @entries.size >= @entries_max
          entry = @entries[key] = { tokens: capacity.to_f, updated_at: now }
        end
        entry[:tokens] = [capacity, entry[:tokens] + (now - entry[:updated_at]) * rate].min
        entry[:updated_at] = now
        return ((1 - entry[:tokens]) / rate).ceil if entry[:tokens] < 1
        entry[:tokens] -= 1
        nil
      end
    end

    private

    def parse_network(cidr, name: "PROXY_TRUSTED_CIDR")
      return if cidr.to_s.empty?
      raise ArgumentError unless /\A[^\/]+\/\d+\z/.match?(cidr)
      IPAddr.new(cidr)
    rescue ArgumentError, IPAddr::InvalidAddressError
      raise ArgumentError, "#{name} must contain an IPv4 or IPv6 CIDR"
    end

    def address(value)
      return unless value.is_a?(String) && !value.empty? && !value.include?("/") && !value.include?("%")
      IPAddr.new(value).native
    rescue IPAddr::InvalidAddressError
      nil
    end

    # Work from the socket peer backwards. Earlier client-controlled values have
    # no authority once the chain reaches an address outside the proxy network.
    def client_address(env)
      peer = address(env["REMOTE_ADDR"])
      current = peer
      env["HTTP_X_FORWARDED_FOR"].to_s.split(",", -1).reverse_each do |hop|
        break unless @trusted && current && @trusted.include?(current)
        current = address(hop.strip)
        return peer&.to_s if current.nil?
      end
      # Only Cloudflare's verified nearest edge may supply this header. In
      # particular, do not continue walking client-supplied forwarding entries.
      if current && @trusted_edges.any? { |network| network.include?(current) }
        connecting_ip = address(env["HTTP_CF_CONNECTING_IP"])
        return connecting_ip.to_s if connecting_ip
      end
      current&.to_s
    end
  end
end

class UpdateBlockedDomainsWorker < ApplicationJob
  def perform
    puts "updating blocked domains"
    hostsfile = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
    domains = URI.open(hostsfile, 'r') do |file|
      file.each_line.filter_map { |line| line.split[1] if line.start_with?('0.0.0.0 ') }.uniq
    end
    raise "Downloaded blocklist contains no domains" if domains.empty?

    BlockedDomain.transaction(requires_new: true) do
      BlockedDomain.delete_all
      domains.each { |domain| BlockedDomain.create!(name: domain) }
    end
    puts "updating blocked domains completed"
  end
end

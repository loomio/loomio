class UpdateBlockedDomainsWorker
  include Sidekiq::Worker

  def perform
    puts "updating blocked domains"
    hostsfile = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'
    BlockedDomain.delete_all
    URI.open(hostsfile, 'r').each do |line|
      next unless line.starts_with?('0.0.0.0 ')
      domain = line.split(" ")[1]
      BlockedDomain.create(name: domain)
    end
    puts "updating blocked domains completed"
  end
end



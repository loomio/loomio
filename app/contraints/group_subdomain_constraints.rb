class GroupSubdomainConstraints
  def self.matches?(request)
    request.subdomain.present? && (request.subdomain != ENV['DEFAULT_SUBDOMAIN'])
  end
end

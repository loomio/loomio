class GroupSubdomainConstraints
  def self.matches?(request)
    false
    # request.subdomain.present? && (request.subdomain != ENV['DEFAULT_SUBDOMAIN'])
  end
end

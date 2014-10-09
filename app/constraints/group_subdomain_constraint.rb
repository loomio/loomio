class GroupSubdomainConstraint
  def self.matches?(request)
    request.subdomain.present? && (request.subdomain != ENV.fetch('DEFAULT_SUBDOMAIN', 'www'))
  end
end


class GroupSubdomainConstraint
  def self.matches?(request)
    request.subdomain.present? && (request.subdomain != 'www')
  end
end


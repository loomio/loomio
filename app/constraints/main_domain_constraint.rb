class MainDomainConstraint
  def self.matches?(request)
    !GroupSubdomainConstraint.matches?(request)
  end
end

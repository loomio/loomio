class NotGroupSubdomainConstraints
  def self.matches?(request)
    !GroupSubdomainConstraints.matches?(request)
  end
end

class NextSubdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain == 'next'
  end
end

class AdminRouteConstraint
  def matches?(request)
    Current.user&.is_admin? || false
  end
end

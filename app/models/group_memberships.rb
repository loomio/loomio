module GroupMemberships
  def build_for_user(user, arguments = {})
    result = build(arguments)
    result.user = user
    result.group = proxy_association.owner
    result
  end
end

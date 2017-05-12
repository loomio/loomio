class Pending::IdentitySerializer < Pending::BaseSerializer
  def identity_type
    object.identity_type
  end

  def avatar_kind
    'uploaded'
  end

  def avatar_url
    object.logo
  end
end

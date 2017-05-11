class Pending::IdentitySerializer < Pending::BaseSerializer
  def avatar_kind
    'uploaded'
  end

  def avatar_url
    object.logo
  end
end

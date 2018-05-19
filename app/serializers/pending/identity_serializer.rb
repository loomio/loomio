class Pending::IdentitySerializer < Pending::BaseSerializer
  attributes :legal_accepted_at
  
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

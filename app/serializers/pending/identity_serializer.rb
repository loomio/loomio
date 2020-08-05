class Pending::IdentitySerializer < Pending::BaseSerializer
  def auth_form
    :identity
  end

  def identity_type
    object.identity_type
  end

  def avatar_kind
    if object.logo.present?
      'uploaded'
    else
      'initials'
    end
  end

  def avatar_url
    object.logo
  end
end

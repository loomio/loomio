class AnonymousUser < LoggedOutUser
  def name
    I18n.t(:'common.anonymous')
  end

  def username
    :anonymous
  end

  def avatar_kind
    'initials'
  end

  def avatar_initials
    "👤"
  end
end

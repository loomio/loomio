module NullUser
  include AvatarInitials
  attr_accessor :name, :email, :avatar_initials
  alias :read_attribute_for_serialization :send

  def votes
    Vote.none
  end

  def memberships
    Membership.none
  end

  def notifications
    Notification.none
  end

  def locale
    I18n.locale
  end

  def avatar_url(size)
    nil
  end

  def avatar_kind
    'initials'
  end

  def is_member_of?(group)
    false
  end

  def is_admin_of?(group)
    false
  end

  def can?(*args)
    ability.can?(*args)
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def experiences
    {}
  end

end

class LoggedOutUser
  include AvatarInitials
  attr_accessor :name, :email, :avatar_initials

  def initialize(name: nil, email: nil)
    @name = name
    @email = email
    set_avatar_initials if (@name || @email)
  end

  def avatar_kind
    'initials'
  end

  def deleted_at
    nil
  end


  def id
    nil
  end

  def is_logged_in?
    false
  end

  def is_logged_out?
    !is_logged_in?
  end

  def uses_markdown?
    false
  end

  def belongs_to_manual_subscription_group?
    false
  end

  def locale
    nil
  end

  def selected_locale
    nil
  end
end

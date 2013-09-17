class Visitor
  include AvatarInitials

  attr_accessor :name, :email, :avatar_initials

  def initialize(name, email)
    @name = name
    @email = email
  end

  def avatar_kind
    'initials'
  end

  def deleted_at
    nil
  end
end

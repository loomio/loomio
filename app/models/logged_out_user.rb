class LoggedOutUser
  include NullUser
  attr_accessor :name, :email, :avatar_initials

  def initialize(name: nil, email: nil)
    @name = name
    @email = email
    set_avatar_initials if (@name || @email)
  end

  def id
    nil
  end

  def created_at
    nil
  end
end

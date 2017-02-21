class LoggedOutUser
  include NullUser

  def initialize(name: nil, email: nil)
    @name = name
    @email = email
    set_avatar_initials if (@name || @email)
  end
end

class LoggedOutUser
  include NullUser
  attr_accessor :name, :email, :avatar_initials

  def initialize(name: nil, email: nil)
    @name = name
    @email = email
    set_avatar_initials if (@name || @email)
  end

  NIL_METHODS = [:id, :participation_token, :created_at]
  NIL_METHODS.each { |method| define_method(method, -> { nil }) }

  def avatar_url(size)
    nil
  end

  def avatar_kind
    'initials'
  end
end

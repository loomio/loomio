class LoggedOutUser
  include NullUser
  attr_accessor :name, :email, :participation_token, :avatar_initials

  def initialize(name: nil, email: nil, participation_token: nil)
    @name = name
    @email = email
    @participation_token = participation_token
    set_avatar_initials if (@name || @email)
  end

  NIL_METHODS = [:id, :created_at, :presence, :restricted]
  NIL_METHODS.each { |method| define_method(method, -> { nil }) }

  def avatar_url(size)
    nil
  end

  def avatar_kind
    'initials'
  end
end

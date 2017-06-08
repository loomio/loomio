class LoggedOutUser
  include NullUser
  attr_accessor :name, :email, :participation_token, :avatar_initials

  def initialize(name: nil, email: nil, participation_token: nil)
    @name = name
    @email = email
    @participation_token = participation_token
    set_avatar_initials if (@name || @email)
  end

  NIL_METHODS = [:id, :created_at, :presence, :restricted, :persisted?]
  FALSE_METHODS = [:save, :persisted?]

  NIL_METHODS.each   { |method| define_method(method, -> { nil }) }
  FALSE_METHODS.each { |method| define_method(method, -> { false }) }

  def avatar_url(size = nil)
    nil
  end

  def email_status
    :unused
  end

  def avatar_kind
    'initials'
  end
end

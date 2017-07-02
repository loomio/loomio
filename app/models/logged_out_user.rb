class LoggedOutUser
  include Null::User
  attr_accessor :name, :email, :participation_token, :avatar_initials

  def initialize(name: nil, email: nil, participation_token: nil)
    @name = name
    @email = email
    @participation_token = participation_token
    set_avatar_initials if (@name || @email)
    apply_null_methods!
  end

  def nil_methods
    super + [:id, :created_at, :avatar_url, :presence, :restricted, :persisted?]
  end

  def false_methods
    super + [:save, :persisted?]
  end

  def errors
    ActiveModel::Errors.new self
  end

  def email_status
    :unused
  end

  def avatar_kind
    'initials'
  end
end

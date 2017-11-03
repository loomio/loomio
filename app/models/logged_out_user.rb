class LoggedOutUser
  include Null::User
  include AvatarInitials
  attr_accessor :name, :email, :token, :avatar_initials, :locale

  alias :read_attribute_for_serialization :send

  def initialize(name: nil, email: nil, token: nil, locale: I18n.locale)
    @name = name
    @email = email
    @token = token
    @locale = locale
    set_avatar_initials if (@name || @email)
    apply_null_methods!
  end

  def create_user
    User.create!(name: name, email: email, token: token)
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

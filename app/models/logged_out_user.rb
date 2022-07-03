class LoggedOutUser
  include Null::User
  include AvatarInitials
  attr_accessor :name, :email, :token, :avatar_initials, :locale, :legal_accepted, :recaptcha, :time_zone, :date_time_pref

  alias :read_attribute_for_serialization :send

  def tags
    Tag.none
  end

  def initialize(name: nil, email: nil, token: nil, locale: I18n.locale, time_zone: 'UTC', date_time_pref: 'day_abbr', params: {}, session: {})
    @name = name
    @email = email
    @token = token
    @locale = locale
    @date_time_pref = date_time_pref
    @time_zone = time_zone
    @params = params
    @session = session
    apply_null_methods!
    set_avatar_initials if (@name || @email)
  end

  def group_token
    @params[:group_token] || @session[:pending_group_token]
  end

  def membership_token
    @params[:membership_token] || @session[:pending_membership_token]
  end

  def stance_token
    @params[:stance_token]
  end

  def discussion_reader_token
    @params[:discussion_reader_token]
  end

  def create_user
    User.create(name: name,
                email: email,
                token: token,
                legal_accepted: legal_accepted,
                require_valid_signup: true,
                recaptcha: recaptcha)
  end

  def memberships_count
    0
  end

  def message_channel
    nil
  end

  def nil_methods
    super + [:id, :created_at, :avatar_url, :thumb_url, :presence, :restricted, :persisted?, :secret_token, :content_locale]
  end

  def false_methods
    super + [:save, :persisted?]
  end

  def errors
    ActiveModel::Errors.new self
  end

  def email_status
    User.email_status_for(self.email)
  end

  def avatar_kind
    'initials'
  end
end

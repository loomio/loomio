module NullUser
  include AvatarInitials
  attr_accessor :name, :email, :avatar_initials
  alias :read_attribute_for_serialization :send

  NIL_METHODS   = [:id, :key, :username, :avatar_url, :selected_locale, :deactivated_at, :time_zone, :default_membership_volume, :unsubscribe_token, :created_at, :participation_token]
  FALSE_METHODS = [:is_logged_in?, :uses_markdown?, :is_organisation_coordinator?,
                   :email_when_proposal_closing_soon, :email_missed_yesterday, :email_when_mentioned, :email_on_participation, :is_group_admin?]
  EMPTY_METHODS = [:groups, :group_ids, :adminable_group_ids]
  TRUE_METHODS  = [:angular_ui_enabled, :angular_ui_enabled?]

  NIL_METHODS.each   { |method| define_method(method, -> { nil }) }
  FALSE_METHODS.each { |method| define_method(method, -> { false }) }
  EMPTY_METHODS.each { |method| define_method(method, -> { [] }) }
  TRUE_METHODS.each  { |method| define_method(method, -> { true }) }

  def votes
    Vote.none
  end

  def memberships
    Membership.none
  end

  def notifications
    Notification.none
  end

  def stances
    Stance.none
  end

  def locale
    I18n.locale
  end

  def avatar_url(size)
    nil
  end

  def avatar_kind
    'initials'
  end

  def is_member_of?(group)
    false
  end

  def is_admin_of?(group)
    false
  end

  def can?(*args)
    ability.can?(*args)
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def experiences
    {}
  end

end

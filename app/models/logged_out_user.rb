class LoggedOutUser
  include NullUser

  def initialize(name: nil, email: nil)
    @name = name
    @email = email
    set_avatar_initials if (@name || @email)
  end

  NIL_METHODS   = [:id, :key, :username, :avatar_url, :selected_locale, :deactivated_at, :time_zone, :default_membership_volume, :unsubscribe_token, :created_at, :participation_token]
  FALSE_METHODS = [:is_logged_in?, :uses_markdown?, :is_organisation_coordinator?,
                   :email_when_proposal_closing_soon, :email_missed_yesterday, :email_when_mentioned, :email_on_participation, :is_group_admin?]
  EMPTY_METHODS = [:groups, :group_ids, :adminable_group_ids]
  TRUE_METHODS  = [:angular_ui_enabled, :angular_ui_enabled?]

  NIL_METHODS.each   { |method| define_method(method, -> { nil }) }
  FALSE_METHODS.each { |method| define_method(method, -> { false }) }
  EMPTY_METHODS.each { |method| define_method(method, -> { [] }) }
  TRUE_METHODS.each  { |method| define_method(method, -> { true }) }

end

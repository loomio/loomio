module NullUser
  include AvatarInitials
  alias :read_attribute_for_serialization :send

  NIL_METHODS   = [:key, :username, :short_bio, :selected_locale, :deactivated_at, :time_zone, :default_membership_volume, :unsubscribe_token, :slack_identity, :facebook_identity, :encrypted_password]
  FALSE_METHODS = [:is_logged_in?, :uses_markdown?, :email_when_proposal_closing_soon,
                   :email_missed_yesterday, :email_when_mentioned, :email_on_participation]
  EMPTY_METHODS = [:groups, :group_ids, :adminable_group_ids]
  TRUE_METHODS  = [:angular_ui_enabled, :angular_ui_enabled?]
  NONE_METHODS  = [:votes, :memberships, :notifications, :polls, :stances, :login_tokens]

  NIL_METHODS.each   { |method| define_method(method, -> { nil }) }
  FALSE_METHODS.each { |method| define_method(method, -> { false }) }
  EMPTY_METHODS.each { |method| define_method(method, -> { [] }) }
  TRUE_METHODS.each  { |method| define_method(method, -> { true }) }
  NONE_METHODS.each  { |method| define_method(method, -> { method.to_s.singularize.classify.constantize.none }) }

  def errors
    ActiveModel::Errors.new self
  end

  def participated_polls
    Poll.none
  end

  def email_communities
    Communities::Base.none
  end

  def communities
    Communities::Base.none
  end

  def identities
    Identities::Base.none
  end

  def stances
    Stance.none
  end

  def locale
    I18n.locale
  end

  def is_member_of?(group)
    false
  end

  def is_admin_of?(group)
    false
  end

  def associate_with_identity(identity)
    nil
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

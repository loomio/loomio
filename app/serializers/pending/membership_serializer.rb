class Pending::MembershipSerializer < Pending::BaseSerializer
  attribute :token

  def identity_type
    :membership
  end

  def has_token
    true
  end

  def email_status
    nil
  end

  def avatar_initials
    object.user.get_avatar_initials
  end

  def name
    object.user.name
  end

  def email
    object.user.email
  end

  private

  def has_name?
    object.user.name.present?
  end

  alias :include_avatar_initials? :has_name?
end

class Pending::MembershipSerializer < Pending::BaseSerializer
  attributes :token, :group_id

  def auth_form
    false  
  end

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
    object.user&.get_avatar_initials
  end

  def name
    object.user&.name
  end

  def email
    object.user&.email
  end

  def group_id
    object.group_id
  end

  private

  def has_name?
    object.user&.name.present?
  end

  alias :include_avatar_initials? :has_name?
end

class Pending::GroupSerializer < Pending::BaseSerializer
  attribute :token

  def has_token
    true
  end

  def token
    object.token
  end

  def include_email_status?
    false
  end

  def include_email?
    false
  end

  def email
    nil
  end

  def name
    nil
  end

  def identity_type
    :group
  end
end

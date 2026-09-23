class Pending::UserSerializer < Pending::BaseSerializer
  attributes :legal_accepted_at, :legal_acceptance_required, :incomplete, :name_managed

  def legal_acceptance_required
    object.legal_acceptance_required?
  end

  def incomplete
    true
  end

  def name_managed
    Hash(scope)[:name_managed]
  end

  private

  def has_token
    Hash(scope)[:has_token]
  end

  def user
    object
  end

  def email_status
    User.email_status_for(object.email)
  end
end

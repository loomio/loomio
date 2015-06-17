InvitationParser = Struct.new(:invitations) do

  def new_emails
    @new_emails ||= invitations_by_type(:email, :email) + invitations_by_type(:contact, :email)
  end

  def new_members
    @new_members ||= User.find(invitations_by_type(:user, :id) + new_group_memberships)
  end

  private

  def new_group_memberships
    Membership.where(group_id: invitations_by_type(:group, :id)).pluck(:user_id)
  end

  def invitations_by_type(type, field)
    invitations.select { |invitation| invitation[:type].to_s == type.to_s }
               .map    { |invitation| invitation[field] }
  end

end

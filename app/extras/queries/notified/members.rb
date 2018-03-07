Queries::Notified::Members = Struct.new(:model, :expand_group) do
  def results
    [
      group_members,
      guest_members,
      public_members,
      invitation_members
    ].flatten.compact
  end

  private

  def public_members
    Members::Public.new(model) if !expand_group && model.anyone_can_participate
  end

  def group_members
    Members::Group.new(model) if !expand_group && model.group.presence
  end

  def guest_members
    if expand_group
      model.group.members
    else
      model.guest_members
    end.with_last_notified_at(model).map { |user| Members::User.new(user) }
  end

  def invitation_members
    if expand_group
      model.group.invitations
    else
      model.guest_invitations
    end.pending.with_last_notified_at.map { |invitation| Members::Invitation.new(invitation) }
  end
end

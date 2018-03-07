Queries::Notified::Members = Struct.new(:model, :user) do
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
    Members::Public.new(model) if model.anyone_can_participate
  end

  def group_members
    Members::Group.new(model) if model.group.presence
  end

  def guest_members
    model.guest_members.with_last_notified_at(model).map { |user| Members::User.new(user) }
  end

  def invitation_members
    model.guest_invitations.pending.with_last_notified_at.map { |invitation| Members::Invitation.new(invitation) }
  end
end

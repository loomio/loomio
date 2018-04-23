class ConvertInvitationsToMemberships
  def self.convert(invitations:)
    to_migrate = invitations
      .joins("LEFT OUTER JOIN memberships ON memberships.token = invitations.token")
      .where("memberships.token": nil, single_use: true, accepted_at: nil, cancelled_at: nil)
      .order(created_at: :desc)
      .limit(limit)
    puts "converting #{to_migrate.length} invitations to memberships"

    Membership.import(to_migrate.map do |invitation|
      Memberships.new(
        token:      invitation.token,
        group_id:   invitation.group_id,
        inviter_id: invitation.inviter_id,
        volume:     Membership.volumes[:normal],
        user:       User.new(email: invitation.recipient_email, name: invitation.recipient_name)
      )
    )
  end
end

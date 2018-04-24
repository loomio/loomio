require_relative './models/invitation.rb'
class ConvertInvitationsToMemberships
  def self.convert(invitations:, limit:)

    to_migrate = invitations
      .joins("LEFT OUTER JOIN memberships ON memberships.token = invitations.token")
      .where("memberships.token": nil, single_use: true, accepted_at: nil, cancelled_at: nil).where.not(created_at: nil).where.not(recipient_email: "contact@loomio.org")
      .order(created_at: :desc)
      .limit(limit)
    puts "converting #{to_migrate.length} invitations to memberships"

    users = to_migrate.map do |invitation|
      User.new(email: invitation.recipient_email.match(Devise.email_regexp).to_s).tap do |u|
        u.memberships.build(
          created_at: invitation.created_at,
          token:      invitation.token,
          group_id:   invitation.group_id,
          inviter_id: invitation.inviter_id,
          user:       u,
          volume:     Membership.volumes[:normal])
      end
    end.compact
    User.import(users, recursive: true)
  end
end

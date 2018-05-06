require_relative './legacy/convert_invitations_to_memberships'

class MoveInvitationsToMemberships < ActiveRecord::Migration[5.1]
  def change
    ConvertInvitationsToMemberships.convert(invitations: Invitation.where('invitations.created_at > ?', 1.month.ago), limit: nil)
  end
end

class MigrateInvitations
  def self.now
    pending_invitees = User.where('invitation_sent_at is not null and invitation_accepted_at is null')
    pending_invitees.each do |invited_user|
      next unless invited_user.groups.present?
      invitation = CreateInvitation.to_join_group(recipient_email: invited_user.email,
                                     inviter: User.find(invited_user.invited_by_id),
                                     group: invited_user.groups.first)
      invitation.update_attribute(:token, invited_user.invitation_token)
      puts "migrated #{invited_user.email}"
    end
  end

  def self.destroy_old_users
    pending_invitees = User.where('invitation_sent_at is not null and invitation_accepted_at is null')
    pending_invitees.each do |invited_user|
      invited_user.destroy
    end
  end
end

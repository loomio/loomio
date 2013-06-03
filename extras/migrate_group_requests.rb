class MigrateGroupRequests
  def self.now
    @ben = User.find_by_email('ben@loomio.org')
    GroupRequest.where(status: 'approved', approved_at: nil).each do |gr|
      invitation = CreateInvitation.to_start_group(recipient_email: gr.admin_email, 
                                                   inviter: @ben,
                                                   group: gr.group)
      invitation.token = gr.token
      invitation.save!
    end
  end
end

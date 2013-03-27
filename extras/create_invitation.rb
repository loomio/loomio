class CreateInvitation
  def self.to_start_group!(args)
    args[:to_be_admin] = true
    Invitation.create(args)
  end

end

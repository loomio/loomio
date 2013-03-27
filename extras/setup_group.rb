class SetupGroup
  attr_accessor :group_request

  def initialize(group_request)
    self.group_request = group_request
  end

  def approve_group_request!(args)

    @group = Group.new
    @group.group_request = group_request

    %w[name country_name cannot_contribute max_size sectors other_sector].each do |attr|
      @group.send("#{attr}=", group_request.send(attr))
    end

    group_request.approve!(args)
    @group.save
    @group
  end

  def send_invitation_to_start_group!(args)
    StartGroupMailer.invite_admin_to_start_group(args[:invitation], args[:message_body]).deliver
  end

end

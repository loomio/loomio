class StartGroupJob < ActiveJob::Base
  def perform(params)
    group = GroupWithCreator.new(params).group
    GroupService.create(group: group, actor: LoggedOutUser.new)
    InvitationService.invite_admin_to_group(group: group,
                                            name:  params[:name],
                                            email: params[:email])
  end
end

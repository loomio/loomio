class StartGroupJob < ActiveJob::Base
  def perform(group_with_creator)
    GroupService.create(group: group_with_creator.group, actor: LoggedOutUser.new)
    InvitationService.invite_admin_to_group(group: group_with_creator.group,
                                            name:  group_with_creator.name,
                                            email: group_with_creator.email)
  end
end

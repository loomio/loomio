class Api::V1::GroupFollowsController < Api::V1::RestfulController
  before_action :require_current_user

  def create
    self.resource = GroupFollowService.create(
      group_follow: GroupFollow.new(group: Group.find(params.require(:group_id))),
      actor: current_user
    )
    respond_with_group(resource.group)
  end

  def destroy
    self.resource = current_user.group_follows.find_by!(group_id: params.require(:id))
    group = resource.group
    GroupFollowService.destroy(group_follow: resource, actor: current_user)
    respond_with_group(group)
  end

  private

  def respond_with_group(group)
    respond_with_collection(records: [ group ], serializer: GroupSerializer, root: :groups)
  end
end

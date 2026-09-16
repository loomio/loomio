class Api::V1::GroupFollowsController < Api::V1::RestfulController
  before_action :require_current_user

  def create
    self.resource = GroupFollow.new(group: Group.find(params.require(:group_id)))
    GroupFollowService.create(group_follow: resource, actor: current_user)
    respond_with_group
  end

  def destroy
    self.resource = current_user.group_follows.find_by!(group_id: params.require(:group_id))
    group = resource.group
    GroupFollowService.destroy(group_follow: resource, actor: current_user)
    self.resource = group
    respond_with_resource(serializer: GroupSerializer, root: :groups)
  end

  private

  def respond_with_group
    self.resource = resource.group
    respond_with_resource(serializer: GroupSerializer, root: :groups)
  end
end

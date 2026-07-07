class Api::V1::TagsController < Api::V1::RestfulController
  private
  def respond_with_group
    self.resource = resource.group.reload
    respond_with_resource
  end

  def create_response
    respond_with_group
  end

  def destroy_response
    respond_with_group
  end

  def accessible_records
    Tag.where(group_id: @group.parent_or_self.id).order(:name)
  end

  def load_and_authorize_group
    @group = Group.find(params[:group_id])
    current_user.ability.authorize!(:update, @group.parent_or_self)
  end
end

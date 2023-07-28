class API::V1::TagsController < API::V1::RestfulController
  def priority
    load_and_authorize_group
    Array(params[:ids]).each_with_index do |id, index|
      Tag.where(id: id, group_id: @group.id).update_all(priority: index)
    end

    instantiate_collection

    # rember to live update too
    respond_with_collection
  end

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
    Tag.where(group_id: @group.id)
  end

  def load_and_authorize_group
    @group = Group.find(params[:group_id])
    current_user.ability.authorize!(:update, @group)
  end
end

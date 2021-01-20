class API::V1::TagsController < API::V1::RestfulController
  def show
    load_and_authorize(:tag)
    respond_with_resource
  end

  def update_model
    self.resource = load_and_authorize(:discussion, :update)
    TagService.update_model(discussion: @discussion, tags: params[:tags])
    respond_with_resource
  end

  def index
    instantiate_collection { |collection| collection.where(group: load_and_authorize(:group)) }
    respond_with_collection
  end

  private

  def accessible_records
    current_user.tags
  end
end

class ::API::TagsController < API::RestfulController

  def show
    load_and_authorize(:tag)
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

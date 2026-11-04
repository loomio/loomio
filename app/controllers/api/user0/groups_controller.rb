class Api::User0::GroupsController < Api::User0::BaseController
  def show
    self.resource = load_and_authorize(:group)
    respond_with_resource
  end

  def index
    self.collection = current_user.groups.order(:id)
    self.collection_count = collection.count
    self.collection = page_collection_bounded(collection)
    respond_with_collection
  end
end

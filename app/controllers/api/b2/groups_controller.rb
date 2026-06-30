class Api::B2::GroupsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:group)
    respond_with_resource
  end

  def index
    self.collection = current_user.groups
    respond_with_collection
  end
end

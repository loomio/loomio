class GroupsController < BaseController
  def create
    build_resource
    @group.owner = current_user
    create!
  end
end

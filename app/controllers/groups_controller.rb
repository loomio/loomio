class GroupsController < BaseController
  def create
    build_resource
    @group.users << current_user
    create!
  end
end

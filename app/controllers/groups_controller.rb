class GroupsController < BaseController
  def create
    build_resource
    create!
  end
end

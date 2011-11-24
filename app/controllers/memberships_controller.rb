class MembershipsController < BaseController
  def update
  end
  def create
    build_resource
    @membership.user = current_user
    @membership.access_level = 'request'
    create!
  end
end

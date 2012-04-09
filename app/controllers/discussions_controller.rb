class DiscussionsController < BaseController
  load_and_authorize_resource

  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    redirect_to motion_url(resource.motions.first)
  end
end

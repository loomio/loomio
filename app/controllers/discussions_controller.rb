class DiscussionsController < BaseController
  load_and_authorize_resource

  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    redirect_to group_url(resource.group)
  end
end

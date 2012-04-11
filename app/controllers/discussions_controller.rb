class DiscussionsController < BaseController
  load_and_authorize_resource

  # NOTE (Jon): this should probably be moved into
  # the CommentsController
  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    redirect_to motion_url(resource.motions.first)
  end
end

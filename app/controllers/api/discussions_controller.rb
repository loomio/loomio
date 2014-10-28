class API::DiscussionsController < API::BaseController
  def show
    @discussion = Discussion.friendly.find(params[:id])
    authorize! :show, @discussion
    render json: [@discussion], root: :discussions
  end
end

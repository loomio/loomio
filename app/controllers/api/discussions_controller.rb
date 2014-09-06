class API::DiscussionsController < API::BaseController
  def show
    @discussion = Discussion.find(params[:id])
    render json: @discussion
  end
end

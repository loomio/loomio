class Api::DiscussionsController < Api::BaseController
  def show
    @discussion = Discussion.find(params[:id])
  end
end

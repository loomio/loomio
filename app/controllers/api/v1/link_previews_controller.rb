class API::V1::LinkPreviewsController < API::V1::RestfulController
  def create
    # require logged in user
    # add rate limit of 100 per hour per user
    previews = LinkPreviewService.fetch_urls(params[:urls])
    render json: {previews: previews}
  end
end

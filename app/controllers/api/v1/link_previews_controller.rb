class API::V1::LinkPreviewsController < API::V1::RestfulController
  def create
    # require logged in user
    # add rate limit of 100 per hour per user
    previews = LinkPreviewService.fetch_urls(filtered_urls)
    render json: {previews: previews}
  end

  private
  def filtered_urls
    known_urls = []
    if d = Discussion.find_by(id: params[:discussion_id])
      known_urls = DiscussionService.extract_link_preview_urls(d)
    end
    params[:urls].reject {|url| known_urls.include?(url) }
  end
end

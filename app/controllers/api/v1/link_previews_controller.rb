class Api::V1::LinkPreviewsController < Api::V1::RestfulController
  def create
    # require logged in user
    # add rate limit of 100 per hour per user
    previews = LinkPreviewService.fetch_urls(filtered_urls)
    render json: {previews: previews}
  end

  private
  def filtered_urls
    known_urls = []
    if topic = Topic.find_by(id: params[:topic_id])
      known_urls = TopicService.extract_link_preview_urls(topic)
    end
    params[:urls].reject {|url| known_urls.include?(url) }
  end
end

class Api::V1::LinkPreviewsController < Api::V1::RestfulController
  before_action :require_current_user

  def create
    unless ThrottleService.can?(key: 'LinkPreviews', id: current_user.id, max: 20, per: 'hour')
      render json: { error: 'Rate limit exceeded' }, status: 429
      return
    end
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

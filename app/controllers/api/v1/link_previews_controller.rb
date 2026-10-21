class Api::V1::LinkPreviewsController < Api::V1::RestfulController
  before_action :require_current_user

  def create
    urls = filtered_urls
    unless ThrottleService.can?(key: 'LinkPreviews', id: current_user.id, max: 20, per: 'hour') &&
           ThrottleService.can?(key: 'LinkPreviewsGlobal', max: 100, per: 'hour')
      render json: { error: 'Rate limit exceeded' }, status: 429
      return
    end
    previews = SafeHttpService.fetch_urls(urls)
    render json: {previews: previews}
  end

  private
  def filtered_urls
    known_urls = []
    if topic = Topic.find_by(id: params[:topic_id])
      current_user.ability.authorize!(:show, topic)
      known_urls = TopicService.extract_link_preview_urls(topic)
    end
    params[:urls].reject {|url| known_urls.include?(url) }
  end
end

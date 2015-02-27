class API::SearchResultsController < API::RestfulController
  def index
    @search_results = ThreadSearchQuery.search(params[:q], user: current_user, limit: 10)
    render json: @search_results, each_serializer: SearchResultSerializer
  end
end

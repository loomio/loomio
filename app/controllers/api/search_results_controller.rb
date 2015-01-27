class API::SearchResultsController < API::BaseController
  def index
    @search = Search.new(current_user, params[:q], 5)
    render json: ActiveModel::ArraySerializer.new(@search.results, each_serializer: SearchResultSerializer, root: :search_results)
  end
end

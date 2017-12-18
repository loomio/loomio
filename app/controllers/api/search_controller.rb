class API::SearchController < API::RestfulController

  def index
    @search = resource_class.weighted_search_for(params[:q], current_user, search_params)
    respond_with_collection
  end

  private

  def search_params
    params.slice(:from, :per).compact
  end

  def serializer_root
    :search_results
  end

  def resource_serializer
    SearchResultSerializer
  end

  def resource_class
    Discussion
  end

end

class API::SearchController < API::RestfulController

  def index
    @search = resource_class.search_for(params[:q], current_user, search_params)
    respond_with_collection serializer: SearchResultSerializer, root: :search_results
  end

  private

  def search_params
    params.slice(:from, :per).compact
  end

  def resource_class
    Discussion
  end

end

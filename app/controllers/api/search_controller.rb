class API::SearchController < API::RestfulController

  def index
    @search = resource_class.weighted_search_for(params[:q], current_user, search_params)
    @search = @search.where('discussions.group_id IN (?)', group_ids) if params[:group_id]
    respond_with_collection
  end

  private
  def group_ids
    if params[:group_id]
      if params[:include_subgroups] == "true"
        Group.find(params[:group_id]).id_and_subgroup_ids
      else
        [params[:group_id]]
      end
    end
  end

  def search_params
    params.slice(:from, :per)
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

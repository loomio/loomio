class API::V1::SearchController < API::V1::RestfulController

  def index

    results = PgSearch.multisearch(params[:query]).where(group_id: group_ids)
    render json: results.map do |res|
      res.slice(:searchable_type, :searchable_id, :group_id, :content)
    end


    # @search = Discussion.weighted_search_for(params[:q].strip, current_user, search_params)
    # @search = @search.where('discussions.group_id IN (?)', group_ids) if params[:group_id]

    # respond_with_collection
  end

  private
  def group_ids
    current_user.group_ids
  end

  def search_params
    params.slice(:from, :per)
  end

  def serializer_root
    :search_results
  end

  def serializer_class
    SearchResultSerializer
  end
end

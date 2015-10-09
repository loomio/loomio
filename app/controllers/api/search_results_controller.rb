class API::SearchResultsController < API::RestfulController

  private

  def instantiate_collection
    self.collection = ThreadSearchQuery.new(params[:q],
                                            user:   current_user,
                                            offset: params[:from],
                                            limit:  params[:per],
                                            since:  params[:since],
                                            till:  params[:until]).search_results
  end
end

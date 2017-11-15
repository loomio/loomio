class API::AnnouncementsController < API::RestfulController
  def notified
    self.collection = Queries::NotifiedSearch.new(params[:q], current_user).results
    respond_with_collection serializer: NotifiedSerializer, root: false
  end
end

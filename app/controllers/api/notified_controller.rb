class API::NotifiedController < API::RestfulController

  def index
    self.collection = Queries::NotifiedSearch.new(params[:q], current_user).results
    respond_with_collection
  end

  private

  def resource_plural
    super.pluralize
  end

  def serializer_root
    false
  end
end

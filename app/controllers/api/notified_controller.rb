class API::NotifiedController < API::RestfulController

  def index
    self.collection = Queries::NotifiedSearch.new(params[:q], current_user).results
    respond_with_collection
  end

  def poll
    self.collection = participants_to_notify.map { |user| Notified::User.new(user) }
    respond_with_collection
  end

  private

  def participants_to_notify
    load_and_authorize(:poll).participants.without(current_user)
  end

  def resource_plural
    super.pluralize
  end

  def serializer_root
    false
  end
end

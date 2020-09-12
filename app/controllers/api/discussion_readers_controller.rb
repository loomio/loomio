class API::DiscussionReadersController < API::RestfulController
  def index
    discussion = load_and_authorize(:discussion)
    instantiate_collection do |collection|
      collection.where(discussion_id: discussion.id)
    end
    respond_with_collection
  end


  private
  def accessible_records
    @accessible_records ||= DiscussionReader.includes(:user)
  end
end

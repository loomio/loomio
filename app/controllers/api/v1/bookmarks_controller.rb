class Api::V1::BookmarksController < Api::V1::RestfulController
  alias :create :update

  def index
    self.collection = current_user.bookmarks.kept.order(created_at: :desc)
    respond_with_collection
  end

  private

  def accessible_records
    current_user.bookmarks
  end

  def load_resource
    self.resource = case action_name
    when 'create', 'update' then resource_class.find_or_initialize_by(user: current_user, bookmarkable: bookmarkable)
    else super
    end
  end

  def bookmarkable
    @bookmarkable ||= resource_params[:bookmarkable_type].classify.constantize.find(resource_params[:bookmarkable_id])
  end
end

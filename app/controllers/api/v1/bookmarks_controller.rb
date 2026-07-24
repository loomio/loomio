class Api::V1::BookmarksController < Api::V1::RestfulController
  BOOKMARKABLE_CLASSES = {
    'Comment' => Comment,
    'Discussion' => Discussion,
    'Outcome' => Outcome,
    'Poll' => Poll
  }.freeze

  alias :create :update

  def index
    self.collection = current_user.bookmarks.kept.where.not(bookmarkable_type: 'Stance').order(created_at: :desc)
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
    bookmarkable_type = resource_params[:bookmarkable_type].classify
    bookmarkable_class = BOOKMARKABLE_CLASSES[bookmarkable_type]
    raise ActiveRecord::RecordNotFound unless bookmarkable_class

    @bookmarkable ||= bookmarkable_class.find(resource_params[:bookmarkable_id])
  end
end

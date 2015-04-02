class API::DiscussionsController < API::RestfulController
  include DashboardHelper

  load_and_authorize_resource only: [:show, :mark_as_read, :set_volume], find_by: :key
  load_resource only: [:create, :update]

  def dashboard_by_date
    @discussions = page_collection dashboard_threads
    respond_with_discussions
  end

  def dashboard_by_group
    @discussions = grouped dashboard_threads.group_by(&:organization_id)
    respond_with_discussions
  end

  def index
    instantiate_collection
    respond_with_discussions
  end

  def show
    respond_with_discussion
  end

  private

  def respond_with_discussion
    if resource.errors.empty?
      render json: DiscussionWrapper.new(discussion: resource, discussion_reader: discussion_reader),
             serializer: DiscussionWrapperSerializer,
             root: 'discussion_wrappers'
    else
      respond_with_errors
    end
  end

  def respond_with_discussions
    render json: DiscussionWrapper.new_collection(user: current_user, discussions: @discussions),
           each_serializer: DiscussionWrapperSerializer,
           root: :discussion_wrappers
  end

  def discussion_params
    params.require(:discussion).permit([:title,
                                        :description,
                                        :uses_markdown,
                                        :group_id,
                                        :private,
                                        :iframe_src])
  end

  def visible_records
    load_and_authorize_group
    if @group
      GroupDiscussionsViewer.for(user: current_user, group: @group)
    else
      Queries::VisibleDiscussions.new(user: current_user)
    end
  end

  private

  def discussion_reader
    @dr ||= DiscussionReader.for(user: current_user, discussion: @discussion)
  end
end

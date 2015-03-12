class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: [:show, :mark_as_read, :set_volume], find_by: :key
  load_resource only: [:create, :update]

  def inbox_current
    @discussions = GroupDiscussionsViewer.for(user: current_user)

    @discussions = @discussions.joined_to_current_motion.
                                preload(:current_motion, {group: :parent}).
                                order('motions.closing_at ASC, last_activity_at DESC').
                                page(params[:page]).per(20)

    respond_with_discussions
  end

  def inbox_unread
    @discussions = GroupDiscussionsViewer.for(user: current_user)

    @discussions = @discussions.unread.joined_to_current_motion.
                                preload(:current_motion, {group: :parent}).
                                order('motions.closing_at ASC, last_activity_at DESC').
                                page(params[:page]).per(20)

    respond_with_discussions
  end

  def index
    instantiate_collection
    respond_with_discussions
  end

  def show
    respond_with_discussion
  end

  def mark_as_read
    event = Event.where(discussion_id: @discussion.id, sequence_id: params[:sequence_id]).first
    discussion_reader.viewed! (event || @discussion).created_at
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
           root: 'discussion_wrappers'
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

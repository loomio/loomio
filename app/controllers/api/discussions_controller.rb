class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: [:show, :mark_as_read], find_by: :key
  load_resource only: [:create, :update]

  def inbox
    @discussions = GroupDiscussionsViewer.for(user: current_user)

    @discussions = @discussions.joined_to_current_motion.
                                preload(:current_motion, {group: :parent}).
                                order('motions.closing_at ASC, last_comment_at DESC').
                                page(params[:page]).per(20)

    respond_with_discussions
  end

  def index
    instantiate_collection
    respond_with_discussions
  end

  def show
    respond_with_resource
  end

  def mark_as_read
    # expect sequence id or just
    event = Event.where(discussion_id: @discussion.id, sequence_id: params[:sequence_id]).first

    if event
      age_of_last_read_item = event.created_at
    else
      age_of_last_read_item = @discussion.created_at
    end

    dr = DiscussionReader.for(discussion: @discussion, user: current_user)

    dr.viewed!(age_of_last_read_item)

    dw = DiscussionWrapper.new(discussion: @discussion,
                               discussion_reader: dr)

    render json: dw, serializer: DiscussionWrapperSerializer, root: 'discussion_wrappers'
  end

  private

  def respond_with_discussions
    discussion_wrappers = DiscussionWrapper.new_collection(user: current_user,
                                                           discussions: @discussions)
    render json: discussion_wrappers,
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
end

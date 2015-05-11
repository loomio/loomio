class API::DiscussionsController < API::RestfulController
  load_and_authorize_resource only: [:show, :mark_as_read, :set_volume]
  load_resource only: [:create, :update]

  def discussions_for_dashboard
    @discussions = page_collection discussions_for_preview
    respond_with_discussions
  end

  def discussions_for_inbox
    @discussions = discussions_for_preview('show_unread')
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
    Queries::VisibleDiscussions.new(user: current_user, groups: current_user.groups)
  end

  private

  def discussions_for_preview(filter = params[:filter])
    case filter
    when 'show_proposals'     then visible_records.not_muted.with_active_motions
    when 'show_participating' then visible_records.not_muted.participating
    when 'show_muted'         then visible_records.muted
    when 'show_unread'        then visible_records.not_muted.unread
    else                           visible_records.not_muted
    end.recent
  end

  def discussion_reader
    @dr ||= DiscussionReader.for(user: current_user, discussion: @discussion)
  end
end

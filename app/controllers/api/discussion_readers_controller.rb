class API::DiscussionReadersController < API::RestfulController

  def load_resource
    load_and_authorize :discussion
    self.resource = DiscussionReader.for(user: current_user, discussion: @discussion)
  end

  def mark_as_read
    load_resource
    resource.viewed! (discussion_event || @discussion).created_at
    respond_with_resource
  end

  private

  def discussion_event
    Event.where(discussion_id: @discussion.id, sequence_id: params[:sequence_id]).first
  end

end

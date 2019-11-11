class API::CommentsController < API::RestfulController
  include UsesDiscussionReaders
  def destroy
    load_resource
    @event = @comment.created_event.parent
    destroy_action
    @event.reload
    render json: EventCollection.new(@event.children).serialize!(default_scope)
  end
end

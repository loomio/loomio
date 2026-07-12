class Api::B2::ThreadsController < Api::B2::BaseController
  def index
    self.collection = TopicQuery.visible_to(user: current_user)
                                .order(last_activity_at: :desc)
                                .offset(params[:offset].to_i)
                                .limit((params[:limit] || 50).to_i)
    respond_with_collection serializer: TopicSerializer, root: :threads
  end

  def show
    self.resource = thread
    respond_with_resource serializer: TopicSerializer, root: :threads
  end

  def items
    self.collection = thread.items.order(:sequence_id)
    respond_with_collection serializer: EventSerializer, root: :items
  end

  def markdown
    render json: {markdown: ThreadMarkdownService.render(topic: thread, user: current_user)}
  end

  private

  def thread
    @thread ||= TopicQuery.visible_to(user: current_user).find(params[:id])
  end
end

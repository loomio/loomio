class Next::InboxController < InboxController
  layout 'next'
  def index
    @discussions = Queries::VisibleDiscussions.new(user: current_user, groups: current_user.groups).
                            order_by_latest_comment.readonly(false)
  end
end
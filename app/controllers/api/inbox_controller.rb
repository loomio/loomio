class API::InboxController < API::BaseController
  def show
    @discussions = GroupDiscussionsViewer.for(user: current_user)

    @discussions = @discussions.joined_to_current_motion.
                                preload(:current_motion, {group: :parent}).
                                order('motions.closing_at ASC, last_comment_at DESC').
                                page(params[:page]).per(20)

    render json: @discussions, root: 'discussions'
  end
end

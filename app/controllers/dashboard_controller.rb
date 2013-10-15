class DashboardController < BaseController
  def show
    @discussions_with_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).with_open_motions.order('motions.closing_at ASC')
    @discussions_without_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).without_open_motions.order('created_at DESC').page(params[:page]).per(20)
  end
end

class DiscussionsController < GroupBaseController
  before_filter :check_group_read_permissions
  load_and_authorize_resource except: :show

  def new
    @discussion = Discussion.new(group: Group.find(params[:discussion][:group_id]))
  end

  def create
    group = Group.find(params[:discussion][:group_id])
    comment = params[:discussion][:comment]
    @discussion = Discussion.create(params[:discussion])
    @discussion.author = current_user
    @discussion.group = group
    if @discussion.save
      @discussion.add_comment(current_user, comment)
      redirect_to @discussion
    else
      redirect_to :back
    end
  end

  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    redirect_to motion_url(resource.default_motion)
  end

  private

    def group
      @group ||= find_group
    end

    def find_group
      if (params[:id] && (params[:id] != "new"))
        Discussion.find(params[:id]).group
      elsif params[:discussion][:group_id]
        Group.find(params[:discussion][:group_id])
      end
    end

end

class DiscussionsController < BaseController
  load_and_authorize_resource

  def new
    @discussion = Discussion.new(group: Group.find(params[:group_id]))
    require 'ap'
    ap @discussion
  end

  def create
    @discussion = Discussion.create(params[:discussion])
    @discusiion.author = current_user
    if @dissussion.save
      #redirect_to :back
    end
  end

  def add_comment
    comment = resource.add_comment(current_user, params[:comment])
    redirect_to motion_url(resource.default_motion)
  end
end

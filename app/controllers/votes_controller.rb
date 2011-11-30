class VotesController < BaseController
  def create
    @vote = Vote.new(position: params[:vote][:position])
    @vote.motion = Motion.find(params[:vote][:motion_id])
    @vote.user = current_user
    if @vote.save
      flash[:notice] = 'Vote saved'
      redirect_to group_motion_path(group_id: @vote.motion.group, 
                                    id: @vote.motion)
    else
      render :edit
    end
  end
end

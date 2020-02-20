class MergeUsersController < ApplicationController
  layout 'basic'

  def confirm
    @source_user = User.active.find_by!(id: params[:source_id])
    @target_user = User.active.find_by!(id: params[:target_id])
    @hash = params[:hash]
    if MergeUsersService.validate(source_user: @source_user, target_user: @target_user, hash: @hash)
      render :confirm
    else
      render 'errors/422', status: 422
    end
  end

  def merge
    @source_user = User.active.find_by!(id: params[:source_id])
    @target_user = User.active.find_by!(id: params[:target_id])
    @hash = params[:hash]
    if MergeUsersService.validate(source_user: @source_user, target_user: @target_user, hash: @hash)
      MigrateUserWorker.perform_async(@source_user.id, @target_user.id)
      render :complete
    else
      render 'errors/422', status: 422
    end
  end

end

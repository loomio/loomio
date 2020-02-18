class MergeUsersController < ApplicationController
  layout 'basic'

  def confirm
    @source_user = User.find_by!(id: params[:source_id])
    @target_user = User.find_by!(id: params[:target_id])
    @hash = params[:hash]
    if UserService.validate_account_merge_hash(source_user: @source_user, target_user: @target_user, hash: @hash)
      render :confirm
    else
      render 'errors/400'
    end
  end

  def merge
    @source_user = User.find_by!(id: params[:source_id])
    @target_user = User.find_by!(id: params[:target_id])
    @hash = params[:hash]
    if UserService.validate_account_merge_hash(source_user: @source_user, target_user: @target_user, hash: @hash)
      MigrateUserWorker.perform_async(@source_user.id, @target_user.id)
      render :complete
    else
      render 'errors/400'
    end
  end

end

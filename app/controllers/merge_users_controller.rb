class MergeUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_target_user, only: [:confirm, :merge]

  def confirm
    source_user = User.active.find_by!(id: params[:source_id])
    target_user = User.active.find_by!(id: params[:target_id])
    hash = params[:hash]
    if MergeUsersService.validate(source_user: source_user, target_user: target_user, hash: hash)
      render Views::MergeUsers::Confirm.new(source_user: source_user, target_user: target_user, hash: hash)
    else
      respond_with_error 422
    end
  end

  def merge
    source_user = User.active.find_by!(id: params[:source_id])
    target_user = User.active.find_by!(id: params[:target_id])
    hash = params[:hash]
    if MergeUsersService.validate(source_user: source_user, target_user: target_user, hash: hash)
      # Invalidate the hash immediately by rotating the source user's secret_token,
      # so the merge URL cannot be replayed before the async worker runs.
      MergeUsersService.invalidate_merge!(source_user: source_user)
      MigrateUserWorker.perform_later(source_user.id, target_user.id)
      render Views::MergeUsers::Complete.new(target_user: target_user)
    else
      respond_with_error 422
    end
  end

  private

  # Only the target user (the email recipient) may confirm or execute a merge.
  # An attacker who intercepts the verification URL must not be able to merge
  # accounts from their own authenticated session.
  def ensure_target_user
    target_user = User.active.find_by!(id: params[:target_id])
    unless current_user.id == target_user.id
      flash[:error] = t('merge_users.not_target_user')
      redirect_to dashboard_path
    end
  end
end

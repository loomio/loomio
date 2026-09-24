class EmailChangesController < ApplicationController
  before_action :forbid_sso_managed_profile
  before_action :load_user
  before_action :protect_confirmation_url

  def confirm
    if EmailChangeService.valid_confirmation?(user: @user, token: params[:token])
      render Views::EmailChanges::Confirm.new(user: @user, token: params[:token])
    else
      respond_with_error 422
    end
  end

  def apply
    EmailChangeService.confirm(user: @user, token: params[:token])
    render Views::EmailChanges::Complete.new(user: @user)
  rescue EmailChangeService::InvalidConfirmation, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    respond_with_error 422
  end

  private

  def forbid_sso_managed_profile
    head :forbidden if UserService.disable_edit_user_profile?
  end

  def load_user
    @user = User.active.find(params[:user_id])
  end

  def protect_confirmation_url
    response.headers['Cache-Control'] = 'no-store'
    response.headers['Referrer-Policy'] = 'no-referrer'
  end
end

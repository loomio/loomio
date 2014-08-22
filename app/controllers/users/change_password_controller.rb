class Users::ChangePasswordController < BaseController

  def show
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    if params[:user][:password] == params[:user][:password_confirmation]
      @user.update_attributes(permitted_params.user)
      sign_in @user, :bypass => true
      flash[:success] = t('success.password_updated')
      redirect_to profile_path
    else
      flash[:error] = t('error.passwords_did_not_match')
      render 'show'
    end
  end
end
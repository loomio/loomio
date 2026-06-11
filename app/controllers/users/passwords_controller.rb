class Users::PasswordsController < ApplicationController
  def update
    user = User.reset_password_by_token(resource_params)

    if user.errors.empty?
      sign_in(user)
      redirect_to dashboard_path, notice: t(:'password_reset.password_updated', default: 'Password updated')
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: user.errors.full_messages.to_sentence }
        format.json { render json: { errors: user.errors }, status: :unprocessable_content }
      end
    end
  end

  private

  def resource_params
    params.fetch(:user, params).permit(:reset_password_token, :password, :password_confirmation)
  end
end

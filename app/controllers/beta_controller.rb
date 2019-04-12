class BetaController < ApplicationController
  def index
    @user = current_user
  end

  def update
    if params[:enable]
      current_user.experiences['vue_client'] = true
      current_user.save
    else
      current_user.experiences.delete('vue_client')
      current_user.save
    end
    redirect_to '/dashboard'
  end
end

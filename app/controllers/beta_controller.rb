class BetaController < ApplicationController
  layout 'basic'
  def index
    @user = current_user
  end

  def update
    if params[:enable] # don't use old client
      current_user.experiences.delete('vue_client')
      current_user.experiences.delete('old_client')
      current_user.save
      redirect_to '/dashboard'
    else #use old client
      current_user.experiences.delete('vue_client')
      current_user.experiences['old_client'] = true
      current_user.save
      redirect_to '/dashboard?old_client=1'
    end
  end
end

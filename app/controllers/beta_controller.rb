class BetaController < ApplicationController
  layout 'basic'
  def index
    @user = current_user
  end

  def update
    if params[:enable]
      current_user.experiences['vue_client'] = true
      current_user.save
      redirect_to '/dashboard?use_vue=1'
    else
      current_user.experiences.delete('vue_client')
      current_user.save
      redirect_to '/dashboard?'
    end
  end
end

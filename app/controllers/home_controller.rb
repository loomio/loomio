class HomeController < ApplicationController
  def index
    @user = current_user
    if @user
      @motions = @user.motions if @user.motions
    end
  end

end

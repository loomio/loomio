class HomeController < ApplicationController
  def index
    @user = current_user
    if @user
      @motions = @user.motions if @user.motions
      @motions_discussing = @user.motions.discussing
      @motions_voting = @user.motions.voting
      @motions_closed = @user.motions.closed
    end
  end

end

class HomeController < ApplicationController
  def index
    @user = current_user
    if @user
      @motions = @user.motions
      @motions_discussing = @user.motions_discussing
      @motions_voting = @user.motions_voting
      @motions_voted = @user.motions_voting.that_user_has_voted_on(@user)
      @motions_closed = @user.motions_closed
      @groups = @user.groups
    end
  end

end

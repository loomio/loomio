class HomeController < ApplicationController
  def index
    @user = current_user
    if @user
      @motions = @user.motions if @user.motions
      @motions_discussing = @user.motions.map{|m| m if m.phase =='discussion'}.compact!
      @motions_voting = @user.motions.map{|m| m if m.phase =='voting' && m.user_has_voted?(@user) == false}.compact!
      @motions_voted = @user.motions.map{|m| m if m.phase =='voting' && m.user_has_voted?(@user) == true}.compact!
      @motions_closed = @user.motions.map{|m| m if m.phase =='closed'}.compact!
    end
  end

end

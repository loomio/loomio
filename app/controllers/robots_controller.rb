class RobotsController < ActionController::Base
  respond_to :text

  def show
    if ENV['ALLOW_ROBOTS']
      render :public_robots
    else
      render :private_robots
    end
  end
end

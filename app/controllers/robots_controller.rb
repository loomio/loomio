class RobotsController < ActionController::Base
  respond_to :text

  def show
    if ENV['ALLOW_ROBOTS']
      head :ok
    else
      render :private_robots
    end
  end
end

class RobotsController < ActionController::Base
  respond_to :text

  def show
    ENV['ALLOW_ROBOTS'].to_i == 1 ? head(:ok) : render(:private_robots)
  end
end

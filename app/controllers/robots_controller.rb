class RobotsController < ActionController::Base

  respond_to :text

  def show
    render robot_file
  end

  def destroy_all_humans
    false
    # whew!
  end

  private

  def robot_file(allow_robots = ENV['ALLOW_ROBOTS'])
    if allow_robots == true || allow_robots =~ /^y|^t|1/i
      :public_robots
    else 
      :private_robots
    end
  end

end

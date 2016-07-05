class RootController < ApplicationController

  def index
    redirect_to destination
  end

  private

  def destination
    if current_user_or_visitor.is_logged_in?
      logged_in_destination
    else
      logged_out_destination
    end
  end

  def logged_out_destination
    new_user_session_path
  end

  def logged_in_destination
    case current_user_groups.count
    when 0 then explore_path
    when 1 then current_user_groups.first
    else        dashboard_path
    end
  end

  def current_user_groups
    @current_user_groups ||= current_user_or_visitor.groups
  end
end

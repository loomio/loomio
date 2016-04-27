class RootController < ApplicationController

  def index
    redirect_to destination
  end

  private

  def destination
    current_user_or_visitor.is_logged_in? ? dashboard_path : new_user_session_path
  end
end

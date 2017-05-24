class RootController < ApplicationController
  def index
    redirect_to dashboard_path
  end
end

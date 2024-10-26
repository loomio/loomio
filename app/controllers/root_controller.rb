class RootController < ApplicationController
  def index
    redirect_to ENV.fetch('FEATURES_DEFAULT_PATH', dashboard_path)
  end
end

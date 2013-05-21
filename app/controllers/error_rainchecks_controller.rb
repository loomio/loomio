class ErrorRainchecksController < ApplicationController

  def error_page
    @not_found_path = params[:not_found]
  end
end

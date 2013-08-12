class ErrorRainchecksController < ApplicationController

  def create
    @error_raincheck = ErrorRaincheck.new(params[:error_raincheck])
    if @error_raincheck.save
      render :action => 'show'
    else
      redirect_to not_found_url
    end
  end

  def show
  end

  def error_page
    @not_found_path = params[:not_found]
    @error_raincheck = ErrorRaincheck.new
  end
end

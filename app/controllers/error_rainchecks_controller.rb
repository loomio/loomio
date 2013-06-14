class ErrorRainchecksController < ApplicationController

  def error_page
    @not_found_path = params[:not_found]
    @error_raincheck = ErrorRaincheck.new
  end

  def create
    @error_raincheck = ErrorRaincheck.new(params[:error_raincheck])
    if @error_raincheck.save
      set_add_loomio_banner
      render :action => 'show'
    else
      redirect_to not_found_url
    end
  end

  def show
  end

  private

  def set_add_loomio_banner
    if current_user
      @add_logo = true
    else
      @add_logo = false
    end
  end
end
class ErrorRainchecksController < ApplicationController

  def error_page
    @not_found_path = params[:not_found]
  end

  def new
    @error_raincheck = ErrorRaincheck.new
  end

  def create
    @error_rainceck = ErrorRaincheck.new(params[:error_raincheck])
      if @error_raincheck.save
        redirect_to email_submitted_path
      else
        redirect_to :back
      end
    end
  end

  # def email_submitted
  #   @email_submitted_path = params[:email_submitted]
  # end

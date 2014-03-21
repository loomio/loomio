class CampaignsController < ApplicationController

  def hide_crowdfunding_banner
    session[:hide_banner] = true

    head :ok
  end

end

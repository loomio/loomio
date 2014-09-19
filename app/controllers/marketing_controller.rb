class MarketingController < ApplicationController
  def index
    if stale?(1) # bump this when we change the frontpage
      render layout: false
    end
  end
end

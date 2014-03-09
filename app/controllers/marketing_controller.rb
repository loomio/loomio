class MarketingController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }

  def index
    render layout: false
  end

end

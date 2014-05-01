class MarketingController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }

  def index
    expires_in 1.hour, :public => true, 'max-stale' => 0
    render layout: false
  end

end

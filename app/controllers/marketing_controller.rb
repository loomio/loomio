class MarketingController < BaseController
  before_filter :authenticate_user!, except: :index
  def index
  end
end
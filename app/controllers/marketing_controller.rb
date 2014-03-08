class MarketingController < BaseController
  before_filter :authenticate_user!, except: :index
  layout false

  def index
  end

end
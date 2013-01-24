class Home2Controller < BaseController
  before_filter :authenticate_user!, :except => :show

  def show
  end
end
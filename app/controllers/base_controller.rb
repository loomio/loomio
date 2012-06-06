class BaseController < InheritedResources::Base
  before_filter :authenticate_user!, :check_browser
  # inherit_resources

  def check_browser
    if browser.ie6? || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end
end

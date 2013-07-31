class ApplicationPagesController < BaseController
  before_filter :authenticate_user!, except: [:about, :blog, :contact, :privacy, :pricing, :terms_of_service]

  def about
  end

  def blog
  end

  def contact
  end

  def privacy
  end

  def pricing
  end

  def terms_of_service
  end
end

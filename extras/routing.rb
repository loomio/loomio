# http://hawkins.io/2012/03/generating_urls_whenever_and_wherever_you_want/
module Routing
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end
end

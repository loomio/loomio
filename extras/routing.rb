module Routing
  module UrlHelpers
    include Rails.application.routes.url_helpers
  end
  extend UrlHelpers
  def self.default_url_options
    ActionMailer::Base.default_url_options
  end
end

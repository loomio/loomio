class DiscussionsController < ApplicationController
  include UsesMetadata
  before_filter :we_dont_serve_images_here_google_bot

  private

  def we_dont_serve_images_here_google_bot
    if request.format == :png
      render :text => 'Not Found', :status => '404'
    end
  end
end

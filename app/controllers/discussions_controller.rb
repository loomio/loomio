class DiscussionsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize
  include EmailHelper
  helper :email

  def show
    if !current_user.is_logged_in? or params[:export]
      @discussion = load_and_authorize(:discussion, :show)
      respond_to do |format|
        format.html
      end
    else
      boot_app
    end
  end
end

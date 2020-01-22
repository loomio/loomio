class DiscussionsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize
  include EmailHelper
  helper :email

  def show
    metadata
    if params[:sign_in] or current_user.is_logged_in?
      boot_app
    else
      @discussion = load_and_authorize(:discussion, :show)
      respond_to do |format|
        format.html
      end
    end
  end
end

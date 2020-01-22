class GroupsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize
  include EmailHelper
  helper :email

  def show
    metadata
    if params[:sign_in] or current_user.is_logged_in?
      boot_app
    else
      @group = load_and_authorize(:group, :show)
      respond_to do |format|
        format.html
      end
    end
  end

  def export
    @exporter = GroupExporter.new(load_and_authorize(:formal_group, :export))

    respond_to do |format|
      format.html
      format.csv { send_data @exporter.to_csv }
    end
  end
end

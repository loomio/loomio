class GroupsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize

  def show
    if !current_user.is_logged_in? or params[:export]
      @group = load_and_authorize(:group, :show)
      respond_to do |format|
        format.html
      end
    else
      boot_app
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

class GroupsController < ApplicationController
  include UsesMetadata
  skip_before_filter :boot_angular_ui, only: :export

  def export
    @exporter = GroupExporter.new(load_and_authorize(:group, :export))
    if ['csv', 'xls'].include? request.format
      send_data @exporter.to_csv
    else
      render layout: false
    end
  end
end

class GroupsController < ApplicationController
  include UsesMetadata
  skip_before_filter :boot_angular_ui, only: :export
  layout false

  def export
    @exporter = GroupExporter.new(load_and_authorize(:group, :export))

    respond_to do |format|
      format.xls { render content_type: :"application/vnd.ms-excel", formats: [:html] }
      format.html
      format.csv { send_data @exporter.to_csv }
    end
  end
end

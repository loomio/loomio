class GroupsController < ApplicationController
  include UsesMetadata
  layout false

  def export
    @exporter = GroupExporter.new(load_and_authorize(:group, :export))

    respond_to do |format|
      format.xls { render formats: [:html] }
      format.html
      format.csv { send_data @exporter.to_csv }
    end
  end
end

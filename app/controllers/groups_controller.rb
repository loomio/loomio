class GroupsController < ApplicationController
  include UsesMetadata
  skip_before_filter :boot_angular_ui, only: :export

  def export
    @exporter = GroupExporter.new(load_and_authorize(:group, :export))
    if request[:format] == 'xls'
      render content_type: 'application/vnd.ms-excel', layout: false
    else
      render layout: false
    end
  end
end

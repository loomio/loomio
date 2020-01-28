class GroupsController < ApplicationController
  def index
    @groups = FormalGroup.limit(10).all
  end

  def export
    @exporter = GroupExporter.new(load_and_authorize(:formal_group, :export))

    respond_to do |format|
      format.html
      format.csv { send_data @exporter.to_csv }
    end
  end
end

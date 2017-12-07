class GroupsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize
  layout false
  before_action :ensure_formal_group, only: :show

  def export
    @exporter = GroupExporter.new(load_and_authorize(:formal_group, :export))

    respond_to do |format|
      format.html
      format.csv { send_data @exporter.to_csv }
    end
  end

  private

  def ensure_formal_group
    load_and_authorize(:formal_group)
  end
end

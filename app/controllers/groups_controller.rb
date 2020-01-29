class GroupsController < ApplicationController
  def index
    @groups = Queries::ExploreGroups.new.search_for(params[:q]).where.not(name: nil).order('groups.memberships_count DESC')
    @total = @groups.count
    limit = params.fetch(:limit, 50)
    @pages = (@total < limit) ? 1 : (@total / limit) + 1
    @page = params.fetch(:page, 1).to_i.clamp(1, @pages)
    @offset = @page == 1 ? 0 : @page * limit
    @groups.limit(limit).offset(@offset)
  end

  def export
    @exporter = GroupExporter.new(load_and_authorize(:formal_group, :export))

    respond_to do |format|
      format.html
      format.csv { send_data @exporter.to_csv }
    end
  end
end

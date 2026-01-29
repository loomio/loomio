class GroupsController < ApplicationController
  before_action :require_signed_in_user_for_explore, only: [:index]

  def index
    @groups = Queries::ExploreGroups.new.search_for(params[:q]).order('groups.memberships_count DESC')
    @total = @groups.count
    limit = params.fetch(:limit, 50)
    if @total < limit
      @pages = 1
    else
      if @total % limit > 0
        @pages = @total / limit + 1
      else
        @pages = @total / limit
      end
    end
    @page = params.fetch(:page, 1).to_i.clamp(1, @pages)
    @offset = @page == 1 ? 0 : ((@page - 1) * limit)
    @groups = @groups.limit(limit).offset(@offset)
  end

  def export
    @exporter = GroupExporter.new(load_and_authorize(:group, :export))
    respond_to do |format|
      format.html
    end
  end

  private

  def require_signed_in_user_for_explore
    require_current_user if AppConfig.app_features[:restrict_explore_to_signed_in_users]
  end
end

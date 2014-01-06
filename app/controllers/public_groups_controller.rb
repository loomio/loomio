class PublicGroupsController < ApplicationController
  def index
    @groups = Group.visible_to_the_public
    if params[:query]
      @groups = @groups.
                search_full_name(params[:query])
    else
      @groups = @groups.sort_by_popularity
    end
    @groups = @groups.page(params[:page])
  end
end

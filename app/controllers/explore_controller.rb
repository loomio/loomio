class ExploreController < ApplicationController
  def search
    @query = params[:query]
    @groups = Group.visible_to_public.
                    search_full_name(@query).
                    page(params[:page])
  end

  def index
    @groups = Group.visible_on_explore_front_page.preload(:category)
    @groups_by_category = @groups.group_by(&:category)
  end

  def category
    @category = Category.find(params[:id])
    @groups = Group.visible_to_public.in_category(@category)
  end
end

class ExploreController < ApplicationController
  def index
    # preload category, also motions..
    @groups = Group.visible_on_explore_front_page.preload(:category)
    @groups_by_category = @groups.group_by(&:category)
  end
end

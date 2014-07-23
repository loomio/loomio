class ExploreController < ApplicationController
  helper_method :selected_category_path, :category_names_and_paths

  def search
    @query = params[:query]
    @groups = Group.visible_to_public.
                    search_full_name(@query).
                    page(params[:page])
  end

  def index
    @groups = Group.visible_on_explore_front_page
  end

  def category
    @category = Category.find(params[:id])
    @groups = Group.visible_to_public.in_category(@category)
  end

  private

  def category_names_and_paths
    @categories = Category.all
    names_and_paths = @categories.map{|c| [I18n.t(c.translatable_name), category_explore_path(c)]}
    names_and_paths.prepend [t(:"group_categories.all"), explore_path]
  end

  def selected_category_path
    if @category
      category_explore_path(@category)
    else
      nil
    end
  end
end

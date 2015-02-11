class ExploreController < ApplicationController
  helper_method :selected_category_path, :category_names_and_paths

  def search
    @query = params[:query]
    @groups = Group.visible_to_public.
                    search_full_name(@query).
                    page(params[:page])
  end

  def index
    @groups = Group.visible_on_explore_front_page.page(params[:page]).per(20)
  end

  def category
    if params[:id] == 'all'
      @groups = Group.visible_to_public.more_than_n_discussions(3).page(params[:page]).per(20)
    else
      @category = Category.find(params[:id])
      @groups = Group.visible_to_public.in_category(@category).more_than_n_discussions(1).page(params[:page]).per(20)
    end
  end

  private

  def category_names_and_paths
    @categories = Category.all
    names_and_paths = @categories.map{|c| [I18n.t(c.translatable_name,default: c.name), category_explore_path(c)]}
    names_and_paths.prepend [t(:"group_categories.all"), category_explore_path(:all)]
    names_and_paths.prepend ["", explore_path]
  end

  def selected_category_path
    if @category
      category_explore_path(@category)
    elsif params[:id] == 'all'
      category_explore_path(:all)
    else
      nil
    end
  end
end

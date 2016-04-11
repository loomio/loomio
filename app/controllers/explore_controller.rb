# class ExploreController < ApplicationController
#   helper_method :selected_category_path, :category_names_and_paths

#   def search
#     @query = params[:query]
#     @groups = Group.visible_to_public.
#                     search_full_name(@query).
#                     page(params[:page])
#   end

#   def index
#     @groups = Group.visible_to_public.more_than_n_discussions(3).page(params[:page]).per(20)
#   end
# end

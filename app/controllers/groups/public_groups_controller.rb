class Groups::PublicGroupsController < BaseController
  before_filter :authenticate_user!, except: [:index]

  def index
    if params[:query]
      @groups = Group.visible_to_the_public.
                search_full_name(params[:query]).
                page(params[:page])
    else
      @groups = Group.visible_to_the_public.page(params[:page])
    end
  end
end

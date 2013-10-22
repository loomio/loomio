class Groups::PublicGroupsController < BaseController
  before_filter :authenticate_user!, except: [:index]

  def index
    @groups = Group.visible_to_the_public
    if params[:query]
      @groups = @groups.
                search_full_name(params[:query])
    elsif !params[:order_direction]
      @groups = @groups.not_featured.sort_by_popularity
    else
      @groups = @groups.order("LOWER(name) #{order_direction}")
    end
    @groups = @groups.page(params[:page])
  end

  private

  def order_direction
    if %w[ASC DESC].include? params[:order_direction]
      params[:order_direction]
    else
      "ASC"
    end
  end

end

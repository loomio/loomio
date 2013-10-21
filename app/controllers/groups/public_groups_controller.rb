class Groups::PublicGroupsController < BaseController
  before_filter :authenticate_user!, except: [:index]

  def index
    @groups = Group.visible_to_the_public
    if params[:query]
      @groups = @groups.
                search_full_name(params[:query])
    end
    @groups = @groups.order("#{order_column} #{order_direction}")
    @groups = @groups.page(params[:page])
  end

  private

  def order_column
    if %w[name memberships_count].include? params[:order_column]
      params[:order_column]
    else
      "name"
    end
  end

  def order_direction
    if %w[ASC DESC].include? params[:order_direction]
      params[:order_direction]
    else
      "ASC"
    end
  end
end

class PublicGroupsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }, unless: :user_signed_in?, :expires_in => 1.hour

  def index
    @groups = Group.include_admins.visible_to_the_public
    if params[:query]
      @groups = @groups.
                search_full_name(params[:query])
    else
      @groups = @groups.sort_by_popularity
    end
    @groups = @groups.page(params[:page])
    
    @feed_url = public_groups_url format: :xml
  end
end

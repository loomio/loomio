class PublicIndexController < ApplicationController

  caches_action :index, :cache_path => Proc.new { |c| c.params }, unless: :user_signed_in?, :expires_in => 1.hour

  def index
    @model = params[:model].to_s.downcase
    @public_items = model.visible_to_the_public
                         .search_or_sort(params[:query])
                         .page(params[:page])
  end

  private
  
  def model
    @model.singularize.humanize.constantize
  end
  
end

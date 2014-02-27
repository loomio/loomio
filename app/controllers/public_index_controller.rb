class PublicIndexController < ApplicationController
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

class RecipesController < ApplicationController
  layout 'basic'
  def export
    @discussion = load_and_authorize(:discussion)
    @html = RecipeService.export_discussion(@discussion)
  end
end
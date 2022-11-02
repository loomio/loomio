class RecipesController < ApplicationController
	def export
		d = load_and_authorize(:discussion)
		html = RecipeService.export_discussion(d)
		render html: html
	end
end
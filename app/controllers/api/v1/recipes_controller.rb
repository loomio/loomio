class API::V1::RecipesController < API::V1::RestfulController
	def index
		@recipe = RecipeService.find_or_create(url: params[:url])
		respond_with_resource
	end

	def create
		# given a url, fetch and save the recipe
		@recipe = RecipeService.create(url: params[:url])
		respond_with_resource
	end
end
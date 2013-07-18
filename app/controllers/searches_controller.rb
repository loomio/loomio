class SearchesController < BaseController
  def show
  	@query = params[:search_form][:query]
    @search_form = SearchForm.new(current_user)
    @search_form.submit(params[:search_form])
  end
end

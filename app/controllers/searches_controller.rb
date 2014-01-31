class SearchesController < BaseController
  def show
    parse_search_form( params[:search_form] )

    @search_form = SearchForm.new(current_user)
    @search_form.submit(@search_params)
  end


  private

  def parse_search_form( form_params )
    @search_params = form_params || generate_empty_search

    @query = @search_params[:query]
  end

  def generate_empty_search
    {query: ''}
  end
end

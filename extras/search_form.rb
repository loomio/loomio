class SearchForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :user
  attr_accessor :query
  attr_accessor :results

  def persisted?
    false
  end

  def initialize(user)
    @user = user
  end

  def submit(params)
    search_query = params[:query]
    @results = @user.motions.search(search_query) + @user.discussions.search(search_query)
  end

end

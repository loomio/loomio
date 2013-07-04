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
    @results = @user.discussions.search(params[:query])
  end

end

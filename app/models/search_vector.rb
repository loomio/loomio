class SearchVector < ActiveRecord::Base
  belongs_to :discussion
  self.table_name = 'discussion_search_vectors'

  def self.execute_search_query(*args)
    connection.execute sanitize_sql_array args
  end
end

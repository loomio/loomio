module Searchable
  extend ActiveSupport::Concern
  include PgSearch::Model

	included do
	  multisearchable
	end

  module ClassMethods
	  def rebuild_pg_search_documents
	    connection.execute pg_search_insert_statement 
	  end

	  def pg_search_insert_statement(id: nil, author_id: nil, discussion_id: nil)
	  	raise "expected to be overwritten"
	  end
  end
end

module PgSearch::Multisearchable
  def update_pg_search_document
    PgSearch::Document.where(searchable: self).delete_all
    ActiveRecord::Base.connection.execute(self.class.pg_search_insert_statement(id: self.id))
  end
end
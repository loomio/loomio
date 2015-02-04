module Searchable
  extend ActiveSupport::Concern

  included do
    after_save :sync_search_vector!, if: :searchable_fields_modified?
    has_one :search_vector, class_name: search_vector_class
  end

  module ClassMethods
    def rebuild_search_index!
      find_each(:batch_size => 100).map(&:sync_search_vector_without_delay!)
    end

    def search_vector_class
      @search_vector_class ||= "SearchVector::#{to_s}".constantize
    end
  end

  def sync_search_vector!
    self.class.search_vector_class.sync_searchable! self
  end
  handle_asynchronously :sync_search_vector!

  private

  def searchable_fields_modified?
    (self.changed.map(&:to_sym) & self.class.search_vector_class.searchable_fields).any?
  end

end

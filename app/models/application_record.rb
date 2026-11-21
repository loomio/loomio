class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_destroy :purge_group_deletion_versions, if: -> { Current.permanently_deleting_group && self.class.respond_to?(:versions_association_name) }

  # Serialize writes without blocking foreign-key checks that reference the row.
  # PostgreSQL takes a stronger lock automatically when a key changes or a row is deleted.
  WRITE_LOCK = 'FOR NO KEY UPDATE'.freeze

  # Lock a scoped batch in one query. Optional columns keep ID-only locks cheap;
  # nested calls join the outer transaction unless a savepoint is requested.
  def self.with_write_lock(*columns, **transaction_options)
    relation = lock(WRITE_LOCK)
    # Keep these filters out of the caller's work and after-commit callbacks.
    default_scoped.scoping do
      transaction(**transaction_options) do
        rows = columns.empty? ? relation.to_a : relation.pluck(*columns)
        # Reads cached before waiting can contain the previous owner's state.
        connection.clear_query_cache
        yield rows
      end
    end
  end

  def with_write_lock(&block)
    with_lock(WRITE_LOCK, &block)
  end

  def named_id
    { "#{ActiveModel::Naming.singular(self)}_id" => id }
  end

  private

  def purge_group_deletion_versions
    # The revisions shown in the app can omit events such as vote weight changes.
    public_send(self.class.versions_association_name).unscope(where: :event).reorder(nil).delete_all
  end
end

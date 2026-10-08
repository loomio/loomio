# Cached counts stored in columns on the record that owns them.
#
# `counter_column :name { |record| count }` defines `update_name`, which
# recounts and writes the column directly. It always writes, so a record whose
# in-memory count is stale still stores the fresh value, and it skips
# validations, callbacks and updated_at.
#
# Child models trigger recounts explicitly with `CounterColumns.recount`, only
# for the changes that affect a count.
module CounterColumns
  extend ActiveSupport::Concern

  class_methods do
    def counter_column(column, &count)
      define_method(:"update_#{column}") { update_column(column, count.call(self)) }
    end
  end

  # Runs owner.method_name once per owner and method after the current
  # transaction commits, or immediately outside a transaction.
  #
  # Counting inside the saving transaction cannot see a concurrent transaction's
  # uncommitted child, so two concurrent saves could each store a count missing
  # the other. After commit, locking the owner row before counting makes each
  # recount wait for the other and then see both children. Recounting once per
  # transaction keeps bulk work, such as many items added under one parent,
  # from recounting the same owner repeatedly. A rolled-back savepoint drops
  # its recount, so a later save in the outer transaction can schedule it again.
  def self.recount(owner, method_name)
    return if owner.nil?

    transaction = owner.class.current_transaction
    return locked_recount(owner, method_name) unless transaction.open?

    key = [owner.class.base_class.name, owner.id, method_name]
    pending = ActiveSupport::IsolatedExecutionState[:counter_column_recounts] ||= Set.new
    return unless pending.add?(key)

    transaction.after_rollback { pending.delete(key) }
    transaction.after_commit do
      pending.delete(key)
      locked_recount(owner, method_name)
    end
  end

  def self.locked_recount(owner, method_name)
    owner.class.transaction do
      # The owner was destroyed meanwhile, such as by a cascade from it.
      next unless owner.class.where(id: owner.id).lock.pick(:id)
      owner.public_send(method_name)
    end
  end
  private_class_method :locked_recount
end

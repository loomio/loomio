module HasImportance
  extend ActiveSupport::Concern

  included do
    enum importances: %w(
      normal_importance
      has_decision
      starred
      starred_and_decision
      pinned
    )

    # store the highest importance value for which the updated model responds truthy
    define_counter_cache(:importance) do |model|
      importances[importances.keys.reverse.detect { |i| model.send(i) }]
    end
  end

  def pinned
    discussion.pinned
  end

  def starred_and_decision
    starred && has_decision
  end

  def has_decision
    @has_decision ||= discussion.polls.active.any?
  end

  def starred
    super if defined?(super)
  end

  # always return lowest importance level if we get this far
  def normal_importance
    true
  end
end

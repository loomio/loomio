# Migration-owned cleanup for making every stance belong to an existing user.
# Accounts deleted between December 2016 and August 2017 left their stances
# behind because User#stances did not yet destroy them.
#
# Poll results are deliberately not recounted: stored results of old polls
# stay as they were recorded. Stance choices cascade through their foreign key;
# timeline items, comments, reactions and other polymorphic dependents of the
# deleted stances are removed by CleanupService's scheduled orphan passes.
module StanceUserReferenceIntegrityCleanup
  def self.run!(connection)
    connection.execute(<<~SQL)
      DELETE FROM stances
      WHERE stances.participant_id IS NULL
         OR NOT EXISTS (SELECT 1 FROM users WHERE users.id = stances.participant_id)
    SQL

    # Inviters, revokers and redactors only record who acted. Losing that user
    # must not remove the vote, so their references become NULL. Clear every
    # missing actor in one update so each row passes all its new foreign keys.
    connection.execute(<<~SQL)
      UPDATE stances
      SET inviter_id = CASE WHEN #{actor_missing_sql("inviter_id")} THEN NULL ELSE inviter_id END,
          revoker_id = CASE WHEN #{actor_missing_sql("revoker_id")} THEN NULL ELSE revoker_id END,
          redactor_id = CASE WHEN #{actor_missing_sql("redactor_id")} THEN NULL ELSE redactor_id END
      WHERE #{actor_missing_sql("inviter_id")}
         OR #{actor_missing_sql("revoker_id")}
         OR #{actor_missing_sql("redactor_id")}
    SQL
  end

  def self.actor_missing_sql(column)
    "(stances.#{column} IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users WHERE users.id = stances.#{column}))"
  end
  private_class_method :actor_missing_sql
end

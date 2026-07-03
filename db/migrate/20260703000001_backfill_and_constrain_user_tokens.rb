# Backfill and constrain nullable user token columns.
#
# The `users` table historically allowed `api_key`, `email_api_key` and
# `unsubscribe_token` to be NULL. The User model's `initialized_with_token`
# after_initialize callback fabricates a random token for any NULL column when
# the record is loaded, which dirties the record and prevents `with_lock`/
# `lock!` from running (see Sentry: Api::V1::SessionsController#create ->
User#increment_failed_attempts!). Persisting those fabricated values
# also silently rotate a user's real key to a throwaway value.
#
# Make the "every user has a token" invariant true at the data layer: backfill
# existing NULLs with a generated token, then add NOT NULL constraints so the
# invariant can't regress. Follows the precedent set by
# AddNotNullToUsersSecretToken, which backfilled secret_token the same way.
class BackfillAndConstrainUserTokens < ActiveRecord::Migration[8.0]
  COLUMNS = %i[api_key email_api_key unsubscribe_token].freeze

  def up
    COLUMNS.each do |column|
      execute "UPDATE users SET #{column} = public.gen_random_uuid() WHERE #{column} IS NULL"
      change_column_null :users, column, false
    end
  end

  def down
    COLUMNS.each { |column| change_column_null :users, column, true }
  end
end
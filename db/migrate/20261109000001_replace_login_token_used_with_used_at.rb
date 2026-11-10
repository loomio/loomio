# used_at records when a login token was redeemed. Tokens that reached the
# failed-attempt limit were also marked used, but were never redeemed, so they
# keep a null used_at; failed_attempts alone now marks them exhausted.
class ReplaceLoginTokenUsedWithUsedAt < ActiveRecord::Migration[8.1]
  FAILED_ATTEMPTS_MAX = 5

  def up
    execute "SET LOCAL lock_timeout = '1s'"
    add_column :login_tokens, :used_at, :datetime
    execute "UPDATE login_tokens SET used_at = updated_at WHERE used AND failed_attempts < #{FAILED_ATTEMPTS_MAX}"
    remove_column :login_tokens, :used
  end

  def down
    execute "SET LOCAL lock_timeout = '1s'"
    add_column :login_tokens, :used, :boolean, null: false, default: false
    execute "UPDATE login_tokens SET used = (used_at IS NOT NULL OR failed_attempts >= #{FAILED_ATTEMPTS_MAX})"
    remove_column :login_tokens, :used_at
  end
end

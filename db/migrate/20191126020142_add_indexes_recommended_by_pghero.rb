class AddIndexesRecommendedByPghero < ActiveRecord::Migration[5.2]
  def change
    execute 'DROP INDEX index_blacklisted_passwords_on_string'
    execute 'CREATE INDEX index_blacklisted_passwords_on_string ON public.blacklisted_passwords USING hash (string)'
    execute 'CREATE INDEX ON delayed_jobs (failed_at)'
    execute 'CREATE INDEX ON events (eventable_id)'
    execute 'CREATE INDEX ON groups (subscription_id)'
    execute 'CREATE INDEX ON notifications (user_id, created_at)'
  end
end

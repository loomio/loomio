class RotateExposedUserApiKeys < ActiveRecord::Migration[8.1]
  def up
    # Group exports could contain API keys that grant instance-wide access as
    # the exported users. Rotate every key so no previously exported key works.
    execute <<~SQL.squish
      UPDATE users
      SET api_key = public.gen_random_uuid()::text
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Exposed API keys cannot be restored"
  end
end

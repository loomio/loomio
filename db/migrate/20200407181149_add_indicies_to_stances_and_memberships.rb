class AddIndiciesToStancesAndMemberships < ActiveRecord::Migration[5.2]
  def change
    add_index :stances, :revoked_at, name: :stances_revoked_at_null, where: 'revoked_at is not null'
  end
end

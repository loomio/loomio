class AddLastAuthenticatedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :omniauth_identities, :last_authenticated_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end

class AddSecretTokenToStances < ActiveRecord::Migration[5.2]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:stances, :secret_token)
      add_column :stances, :secret_token, :string, default:  -> { 'gen_random_uuid()' }
    end
  end
end

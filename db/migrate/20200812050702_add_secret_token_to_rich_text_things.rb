class AddSecretTokenToRichTextThings < ActiveRecord::Migration[5.2]
  def change
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")
    add_column :comments, :secret_token, :string, default:  -> { 'gen_random_uuid()' }
    add_column :discussions, :secret_token, :string, default: -> { 'gen_random_uuid()' }
    add_column :polls, :secret_token, :string, default: -> { 'gen_random_uuid()' }
    add_column :outcomes, :secret_token, :string, default:  -> { 'gen_random_uuid()' }
    add_column :groups, :secret_token, :string, default: -> { 'gen_random_uuid()' }
    add_column :users, :secret_token, :string, default:  -> { 'gen_random_uuid()' }
  end
end

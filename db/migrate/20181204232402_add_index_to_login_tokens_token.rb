class AddIndexToLoginTokensToken < ActiveRecord::Migration[5.1]
  def change
    add_index :login_tokens, :token
  end
end

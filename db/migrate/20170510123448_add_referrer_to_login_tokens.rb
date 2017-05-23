class AddReferrerToLoginTokens < ActiveRecord::Migration
  def change
    add_column :login_tokens, :redirect, :string, null: true
  end
end

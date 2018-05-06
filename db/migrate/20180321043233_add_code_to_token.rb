class AddCodeToToken < ActiveRecord::Migration[5.1]
  def change
    add_column :login_tokens, :code, :integer, null: false, default: 0
  end
end

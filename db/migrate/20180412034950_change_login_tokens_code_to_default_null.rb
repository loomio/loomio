class ChangeLoginTokensCodeToDefaultNull < ActiveRecord::Migration[5.1]
  def change
    change_column :login_tokens, :code, :integer, default: nil
  end
end

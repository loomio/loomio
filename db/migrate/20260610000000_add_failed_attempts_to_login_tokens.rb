class AddFailedAttemptsToLoginTokens < ActiveRecord::Migration[8.0]
  def change
    add_column :login_tokens, :failed_attempts, :integer, null: false, default: 0
  end
end

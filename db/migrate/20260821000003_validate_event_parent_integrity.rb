class ValidateEventParentIntegrity < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :events, :events, column: :parent_id
  end
end

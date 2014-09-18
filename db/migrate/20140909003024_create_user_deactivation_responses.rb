class CreateUserDeactivationResponses < ActiveRecord::Migration
  def change
    create_table :user_deactivation_responses do |t|
      t.references :user, index: true
      t.text :body
    end
  end
end

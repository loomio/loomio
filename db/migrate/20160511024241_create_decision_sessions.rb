class CreateDecisionSessions < ActiveRecord::Migration
  def change
    create_table :decision_sessions do |t|
      t.timestamps null: false
      t.string :initiator_name, null: false
      t.string :initiator_email, null: false
      t.string :base_token, null: false
      t.string :participants, array: true
      t.string :locale, null: false
    end
  end
end

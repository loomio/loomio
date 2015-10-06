class AddFeedback < ActiveRecord::Migration
  def change
    create_table :feedback_responses do |t|
      t.text :feedback
      t.string :version
      t.references :visit
      t.references :user
      t.boolean :processed, default: false
    end
  end
end

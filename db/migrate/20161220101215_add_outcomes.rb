class AddOutcomes < ActiveRecord::Migration
  def change
    create_table :outcomes do |t|
      t.belongs_to :poll
      t.string :statement, null: false
      t.integer :author_id, null: false
      t.timestamps
    end
    remove_column :polls, :outcome, :string
    remove_column :polls, :outcome_author_id, :integer
  end
end

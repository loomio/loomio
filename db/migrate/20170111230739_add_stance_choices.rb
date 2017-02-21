class AddStanceChoices < ActiveRecord::Migration
  def change
    remove_column :stances, :poll_option_id
    remove_column :stances, :score

    create_table :stance_choices do |t|
      t.belongs_to :stance, index: true
      t.belongs_to :poll_option, index: true
      t.integer :score, default: 1, null: false
      t.timestamps
    end
  end
end

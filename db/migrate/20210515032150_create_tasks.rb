class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.references :record, polymorphic: true
      t.references :author, null: false
      t.integer :uid, null: false
      t.string :name, null: false
      t.boolean :done, null: false
      t.datetime :done_at
      t.date :due_on
      t.timestamps
    end

    create_table :tasks_users do |t|
      t.references :task
      t.references :user
      t.timestamps
    end

    add_index :tasks, :due_on
  end
end

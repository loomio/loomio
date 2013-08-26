class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :language
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end

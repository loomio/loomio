class AddEmailTemplateIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :email_template_id, :integer
    add_index :emails, :email_template_id
  end
end

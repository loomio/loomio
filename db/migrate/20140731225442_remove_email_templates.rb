class RemoveEmailTemplates < ActiveRecord::Migration
  def change
    drop_table :emails
    drop_table :email_templates
    drop_table :email_template_sent_to_groups
  end
end

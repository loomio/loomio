class CreateEmailTemplateSentToGroups < ActiveRecord::Migration
  def change
    create_table :email_template_sent_to_groups do |t|
      t.references :email_template
      t.references :group
      t.references :author
      t.string :recipients

      t.timestamps
    end
    add_index :email_template_sent_to_groups, :email_template_id
    add_index :email_template_sent_to_groups, :group_id
    add_index :email_template_sent_to_groups, :author_id
  end
end

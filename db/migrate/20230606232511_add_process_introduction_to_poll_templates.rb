class AddProcessIntroductionToPollTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_templates, :process_introduction, :string
    add_column :poll_templates, :process_introduction_format, :string, default: 'md', null: false
    remove_column :poll_templates, :notify_on_participate
  end
end

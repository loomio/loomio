class AddMeetingDurationToPollTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :poll_templates, :meeting_duration, :integer, default: nil
    add_column :poll_templates, :can_respond_maybe, :boolean, null: false, default: true
    add_column :poll_templates, :poll_option_name_format, :string, null: false, default: 'plain'
    add_column :poll_templates, :link_previews, :jsonb, default: [], null: false
    add_column :poll_templates, :atttachments, :jsonb, default: [], null: false
    change_column :poll_templates, :default_duration_in_days, :integer ,null: false, default: 7
  end
end

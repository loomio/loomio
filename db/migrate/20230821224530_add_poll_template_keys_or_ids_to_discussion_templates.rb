class AddPollTemplateKeysOrIdsToDiscussionTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :discussion_templates, :poll_template_keys_or_ids, :jsonb, default: [], null: false
  end
end

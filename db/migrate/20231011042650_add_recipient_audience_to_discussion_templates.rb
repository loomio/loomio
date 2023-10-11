class AddRecipientAudienceToDiscussionTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :discussion_templates, :recipient_audience, :string
  end
end

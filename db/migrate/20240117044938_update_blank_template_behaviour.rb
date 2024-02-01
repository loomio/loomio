class UpdateBlankTemplateBehaviour < ActiveRecord::Migration[7.0]
  def change
    DiscussionTemplate.where(process_name: "Blank template").update_all(recipient_audience: 'group')
    DiscussionTemplate.where(process_name: "Blank template").update_all(process_introduction: I18n.t('discussion_templates.blank.process_introduction'))
  end
end

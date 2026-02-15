class UpdatePracticeThreadText < ActiveRecord::Migration[8.0]
  def up
    DiscussionTemplate.where(key: 'practice_thread').find_each do |dt|
      dt.update_columns(
        process_subtitle: I18n.t('discussion_templates.practice_thread.process_subtitle_v2'),
        process_introduction: I18n.t('discussion_templates.practice_thread.process_introduction_v2'),
        title: I18n.t('discussion_templates.practice_thread.title_v2'),
        description: I18n.t('discussion_templates.practice_thread.description_v2')
      )
    end
  end

  def down
    DiscussionTemplate.where(key: 'practice_thread').find_each do |dt|
      dt.update_columns(
        process_subtitle: I18n.t('discussion_templates.practice_thread.process_subtitle'),
        process_introduction: I18n.t('discussion_templates.practice_thread.process_introduction'),
        title: I18n.t('discussion_templates.practice_thread.title'),
        description: I18n.t('discussion_templates.practice_thread.description')
      )
    end
  end
end

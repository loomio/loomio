class ConvertDiscussionTemplatesWorker
  include Sidekiq::Worker

  def perform
    Discussion.where(template: true).each do |discussion|
      template = DiscussionTemplate.new(discussion.slice(
          :group_id,
          :author_id,
          :title,
          :description,
          :description_format,
          :tags,
          :max_depth,
          :newest_first,
          :content_locale,
          :link_previews,
          :discarded_at,
          :discarded_by,
          :created_at,
          :updated_at,
          :attachments))

      template.source_discussion_id = discussion.id

      template.save!

      discussion.files.attachments.update_all(
        record_type: 'DiscussionTemplate',
        record_id: template.id
      )

      discussion.image_files.attachments.update_all(
        record_type: 'DiscussionTemplate',
        record_id: template.id
      )

      discussion.discard! 
    end
  end
end

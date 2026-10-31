class AttachmentPermissionService
  # Authorize before assigning files: Active Storage can save attachments
  # immediately on persisted records.
  def self.authorize!(record:, actor:, params: nil)
    topic = record.topic
    return unless topic.attachments_admin_only?
    return if actor.can?(:attach_files, topic)

    return unless record.attachments_added?(params)

    raise CanCan::AccessDenied.new(I18n.t('errors.attachments_admin_only'), :attach_files, topic)
  end

  def self.authorize_topic_settings!(topic:, params:, actor:)
    return unless params.key?(:attachments_admin_only)
    return if ActiveModel::Type::Boolean.new.cast(params[:attachments_admin_only]) == topic.attachments_admin_only

    actor.ability.authorize! :update, topic
  end
end

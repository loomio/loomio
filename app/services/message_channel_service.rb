class MessageChannelService
  def self.publish_models(models, serializer: nil, scope: {}, root: nil, group_id: nil, user_id: nil, topic_id: nil)
    return if models.blank?
    cache = RecordCache.for_collection(models, user_id)
    data = serialize_models(models, serializer: serializer, scope: scope.merge(cache: cache, current_user_id: user_id), root: root)
    publish_serialized_records(data, group_id: group_id, user_id: user_id, topic_id: topic_id)
  end

  def self.serialize_models(models, serializer: nil, scope: {}, root: nil)
    models = Array(models)
    return unless model = models.first
    serializer ||= model.is_a?(Event) ? EventSerializer : "#{model.class}Serializer".constantize
    root       ||= model.is_a?(Event) ? 'events' : model.class.to_s.pluralize.downcase
    ActiveModel::ArraySerializer.new(models, scope: scope, each_serializer: serializer, root: root)
  end

  def self.publish_serialized_records(data, group_id: nil, user_id: nil, topic_id: nil)
    payload = {records: data}

    ActionCable.server.broadcast("user_#{user_id}", payload) if user_id
    ActionCable.server.broadcast("group_#{group_id}", payload) if group_id
    ActionCable.server.broadcast("topic_#{topic_id}", payload) if topic_id
  end

  def self.publish_system_notice(notice, reload = false)
    ActionCable.server.broadcast("notice", {
      version: Version.current,
      notice: notice,
      reload: reload
    })
  end
end

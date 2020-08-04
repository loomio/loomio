class MessageChannelService
  def self.publish_models(models, serializer: nil, root: nil, group_ids: [], user_ids: [])
    models = Array(models)
    model = models.first
    serializer ||= model.is_a?(Event) ? Events::BaseSerializer : "#{model.class}Serializer".constantize
    root       ||= model.is_a?(Event) ? 'events' : model.class.to_s.pluralize.downcase
    data       =   ActiveModel::ArraySerializer.new(models, each_serializer: serializer, root: root).as_json
    publish_serialized_records(data, group_ids: group_ids, user_ids: user_ids)
  end

  def self.publish_serialized_records(data, group_ids: [], user_ids: [])
    MessageBus.publish '/records', data.as_json.as_json, group_ids: group_ids, user_ids: user_ids
  end
end

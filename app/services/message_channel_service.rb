class MessageChannelService
  def self.publish_models(models, serializer: nil, scope: {}, root: nil, group_id: nil, user_id: nil)
    data = serialize_models(models, serializer: serializer, scope: scope, root: root)
    publish_serialized_records(data, group_id: group_id, user_id: user_id)
  end

  def self.serialize_models(models, serializer: nil, scope: {}, root: nil)
    models = Array(models)
    return unless model = models.first
    serializer ||= model.is_a?(Event) ? Events::BaseSerializer : "#{model.class}Serializer".constantize
    root       ||= model.is_a?(Event) ? 'events' : model.class.to_s.pluralize.downcase
    ActiveModel::ArraySerializer.new(models, scope: scope, each_serializer: serializer, root: root)
  end

  def self.publish_serialized_records(data, group_id: nil, user_id: nil)
    REDIS_POOL.with do |client|
      room = "user-#{user_id}" if user_id
      room = "group-#{group_id}" if group_id
      data_str = data.as_json.as_json
      score = client.incr("/records/#{room}/score")
      client.zadd("/records/#{room}", score, data_str)
      client.publish("/records", {room: room, records: data_str, score: score}.to_json)
    end
  end
end

class MessageChannelService
  def self.publish_models(models, serializer: nil, scope: {}, root: nil, group_id: nil, user_id: nil)
    cache = RecordCache.for_collection(models, user_id)
    data = serialize_models(models, serializer: serializer, scope: scope.merge(cache: cache), root: root)
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
    CHANNELS_REDIS_POOL.with do |client|
      room = "user-#{user_id}" if user_id
      room = "group-#{group_id}" if group_id
      data_str = data.as_json.as_json
      score = client.incr("/records/#{room}/score")
      # puts "incrementing score:", room, score, data_str
      client.zadd("/records/#{room}", score, data_str.to_json)
      client.publish("/records", {room: room, records: data_str, score: score}.to_json)
      client.zremrangebyscore("/records/#{room}", "-inf", (score - 200))
    end
  end

  def self.publish_system_notice(notice)
    CHANNELS_REDIS_POOL.with do |client|
      client.publish("/system_notice", {notice: notice}.to_json)
    end
  end
end

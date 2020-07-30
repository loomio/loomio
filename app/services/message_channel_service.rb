class MessageChannelService
  def self.publish_model(model, serializer: nil, root: nil, to: nil)
    serializer ||= "#{model.class}Serializer".constantize
    root       ||= model.class.to_s.pluralize.downcase
    to         ||= model.group.message_channel
    data       =   ActiveModel::ArraySerializer.new([model], each_serializer: serializer, root: root).as_json
    Array(to).each { |channel| MessageBus.publish channel, data }
  end

  def self.publish_records(data, group_ids: [], user_ids: [])
    MessageBus.publish '/records', data, group_ids: group_ids, user_ids: user_ids
  end

  def self.publish_event(event)
    event_data = Events::BaseSerializer.new(event).to_json
    MessageBus.publish event.message_channel, data
  end
end

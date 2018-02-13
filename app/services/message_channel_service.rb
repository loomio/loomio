class MessageChannelService
  def self.publish_model(model, serializer: nil, root: nil, to: nil)
    serializer ||= "#{model.class}Serializer".constantize
    root ||= model.class.to_s.pluralize.downcase
    to ||= model.groups.map(&:message_channel)
    data = ActiveModel::ArraySerializer.new([model], each_serializer: serializer, root: root).as_json
    Array(to).each { |channel| publish_data(data, to: channel) }
  end

  def self.publish_data(data, to: message_channel)
    ActionCable.server.broadcast to, data
  end
end

class Clients::Webhook < Clients::Base

  def post_content!(topic_item, format, webhook)
    post @token, params: serialized_event(topic_item, format, webhook)
  end

  def default_host
    nil
  end

  def require_json_payload?
    true
  end

  def serialized_event(topic_item, format, webhook)
    serializer = [
      "Webhook::#{format.classify}::#{topic_item.kind.classify}Serializer",
      "Webhook::#{format.classify}::#{topic_item.itemable.class}Serializer",
      "Webhook::#{format.classify}::BaseSerializer"
    ].detect { |str| str.constantize rescue nil }.constantize
    serializer.new(topic_item, root: false, scope: {webhook: webhook}).as_json
  end
end

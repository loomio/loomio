class Clients::Webhook < Clients::Base

  def post_content!(event, format, webhook)
    post @token, params: serialized_event(event, format, webhook)
  end

  def default_host
    nil
  end

  def require_json_payload?
    true
  end

  def serialized_event(event, format, webhook)
    serializer = [
      "Webhook::#{format.classify}::#{event.kind.classify}Serializer",
      "Webhook::#{format.classify}::#{event.eventable.class}Serializer",
      "Webhook::#{format.classify}::BaseSerializer"
    ].detect { |str| str.constantize rescue nil }.constantize
    serializer.new(event, root: false, scope: {webhook: webhook}).as_json
  end
end

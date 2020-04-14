class Clients::Webhook < Clients::Base

  def post_content!(event, format)
    post @token, params: serialized_event(event, format)
  end

  def default_host
    nil
  end

  def require_json_payload?
    true
  end

  def serialized_event(event, format)
    serializer = [
      "Webhook::#{format.classify}::#{event.kind.classify}Serializer",
      "Webhook::#{format.classify}::#{event.eventable.class}Serializer",
      "Webhook::#{format.classify}::BaseSerializer"
    ].detect { |str| str.constantize rescue nil }.constantize
    serializer.new(event, root: false).as_json
  end
end

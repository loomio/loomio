class Clients::Microsoft < Clients::Base

  def post_content!(event)
    post @token, params: serialized_event(event)
  end

  def default_host
    nil
  end

  def require_json_payload?
    true
  end
end

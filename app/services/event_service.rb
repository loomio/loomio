class EventService
  def self.broadcast!(event:)
    Clients::Slack.post! event
  end
end

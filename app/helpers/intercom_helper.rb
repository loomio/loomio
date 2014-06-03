module IntercomHelper
  def create_intercom_event(event_name, info={})
    if ENV['INTERCOM_APP_ID']
      Intercom::Event.create({
        event_name: event_name,
        user: current_user
      }.merge(info))
    end
  end
end
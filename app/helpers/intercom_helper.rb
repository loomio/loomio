module IntercomHelper
  def create_intercom_event(event_name)
    if ENV['INTERCOM_APP_ID']
      Intercom::Event.create({
        event_name: event_name,
        user: current_user
      })
    end
  rescue => e
    Airbrake.notify e
  end
end
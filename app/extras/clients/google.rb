class Clients::Google < Clients::Base
  def is_member_of?(calendar_id, uid)
    # TODO: write calendar access google API query
  end

  def post_content!
    # TODO: write calendar create event google API query
    # post "calendar/#{}/events", params: serialized_event(event)
  end

  def host
    # TODO: get correct endpoint
    "https://googleapps.com/apis/calendar".freeze
  end
end

class CalendarInviteSerializer < ActiveModel::Serializer
  attribute :context, key: :@context
  attribute :type,    key: :@type
  attributes :name, :startDate, :duration, :location

  def context
    :"http://schema.org"
  end

  def type
    :"Event"
  end

  def name
    object.statement
  end

  def startDate
    object.poll_option.name
  end

  def duration
    object.custom_fields['event_duration']
  end

  def location
    { :"@type" => :Place, address: { name: object.custom_fields['event_location'] } }
  end
end

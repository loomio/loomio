class CurrentDiscussionWrapperSerializer < DiscussionWrapperSerializer
  
  has_many :initial_events, each_serializer: EventSerializer, root: :events
  attribute :focused_sequence_id

  def initial_events
    event_stream.initial_events
  end

  def focused_sequence_id
    event_stream.focused_sequence_id
  end

  private

  def event_stream
    @event_stream ||= EventStream.new(discussion_reader: object.discussion_reader)
  end
end

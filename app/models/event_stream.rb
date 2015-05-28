class EventStream

  PAGESIZE = 30
  ROLLBACK = 2

  def initialize(discussion_reader:, focused: nil)
    @discussion_reader = discussion_reader
    @discussion = discussion_reader.discussion
    @focused = focused
  end

  def initial_events
    Event.where(discussion: @discussion)
         .where('sequence_id > ?', load_from_event)
         .order(sequence_id: :asc)
         .limit(PAGESIZE)
  end

  def focused_sequence_id
    @focused ||
    @discussion_reader.last_read_sequence_id if @discussion.unread_activity_count > 0 ||
    @discussion.last_sequence_id
  end

  private

  def load_from_event
    if @discussion.events.length <= PAGESIZE
      0
    elsif @focused_sequence_id
      @focused_sequence_id - ROLLBACK
    elsif @discussion_reader.unread_activity_count > 0
      @discussion_reader.last_read_sequence_id - ROLLBACK
    else
      @discussion.last_sequence_id - PAGESIZE + 1
    end
  end
end
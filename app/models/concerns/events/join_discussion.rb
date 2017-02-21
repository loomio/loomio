module Events::JoinDiscussion
  def trigger!
    super
    join_discussion!
  end

  # update discussion reader after thread item creation
  def join_discussion!
    DiscussionReader.for_model(eventable).update_reader(read_at: created_at, participate: true, volume: :loud)
  end
end

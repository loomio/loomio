class Dashboard::MotionSerializer < ::MotionSerializer
  def include_attachments?
    false
  end

  def include_mentioned_usernames?
    false
  end
end

class BlobAttachmentAccess
  # Only Loomio content can keep an ordinary link alive. Active Storage's
  # generated preview and variant attachments are storage bookkeeping.
  RECORD_TYPES = %w[Comment Discussion DiscussionTemplate Group Outcome Poll PollTemplate Stance User].freeze

  def self.live?(blob)
    blob.attachments.where(record_type: RECORD_TYPES).any? do |attachment|
      live_record?(attachment.record)
    end
  end

  def self.live_record?(record)
    case record
    when Comment
      return false if record.discarded?

      # A discarded comment leaves its replies visible. Follow the parent
      # chain to the enclosing discussion or poll, including poll side threads.
      parent = record.parent
      parent = parent.parent while parent.is_a?(Comment)
      live_record?(parent)
    when Outcome, Stance
      live_record?(record.poll)
    when Discussion, Poll
      record.kept? && live_topic?(record.topic)
    when DiscussionTemplate, PollTemplate
      record.kept? && (record.group_id.nil? || live_group?(record.group))
    when Group
      live_group?(record)
    when User
      true
    else
      false
    end
  end

  def self.live_topic?(topic)
    return false unless topic && topic.discarded_at.nil?

    topic.topicable&.kept? && (topic.group_id.nil? || live_group?(topic.group))
  end

  def self.live_group?(group)
    return false unless group.is_a?(Group) && group.kept?

    group.parent_id.nil? || live_group?(group.parent)
  end

  private_class_method :live_record?, :live_topic?, :live_group?
end

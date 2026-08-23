module NotificationDeliveryResolvers
  class CommentRepliedTo < UserMentioned
    def self.deduplication_key(comment, occurrence_key: nil)
      if occurrence_key.blank?
        raise ArgumentError, "comment_replied_to occurrence_key is required"
      end

      "comment_replied_to:comment_#{comment.id}:#{occurrence_key}"
    end
  end
end

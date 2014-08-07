class Events::NewComment < Event
  def self.publish!(comment)
    create!(:kind => "new_comment",
            :eventable => comment,
            :discussion_id => comment.discussion.id)
  end

  def comment
    eventable
  end
end

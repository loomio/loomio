module UserMailerHelper

  def display_discussion_description(discussion, activity_summary)
    if discussion.last_non_comment_activity_at >= activity_summary.last_sent_at
      discussion.description
    else
      truncate(discussion.description, :length => 50, :omission => '...')
    end
  end

  def display_motion_description(motion, activity_summary)
    if motion.last_non_vote_activity_at >= activity_summary.last_sent_at
      motion.description
    else
      truncate(motion.description, :length => 50, :omission => '...')
    end
  end

  def unread_motion_activity?(motion, activity_summary)
    activity_summary.unread_motions_for(motion.group).include?(motion)
  end

  def info_for_avatar(discussion, activity_summary)
    if discussion.created_since?(activity_summary.last_sent_at)
      user = discussion.author
      item_text = t('email.activity_summary.started_a_discussion')
    elsif discussion.modified_since?(activity_summary.last_sent_at)
      activity = activity_summary.latest_discussion_activity_item(discussion)
      user = activity.actor
      item_text = activity.body
    end
    return user, item_text
  end
end

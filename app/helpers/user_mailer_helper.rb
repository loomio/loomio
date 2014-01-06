module UserMailerHelper
  def display_description(description, is_new)
    is_new ? description : truncate(description, :length => 5, :omission => '...')
  end

  def new_and_unread?(motion, activity_summary)
    activity_summary.unread_motions_for(motion.group).include?(motion) && motion.created_since?(activity_summary.last_sent_at)
  end

  def new_or_unread?(motion, activity_summary)
    activity_summary.unread_motions_for(motion.group).include?(motion) || motion.created_since?(activity_summary.last_sent_at)
  end
end

module UserMailerHelper
  def new_discussion?(inbox, discussion, last_summary_at)
    (inbox.unread_discussions_for(discussion.group).include? discussion) && (discussion.created_at > last_summary_at)
  end
end
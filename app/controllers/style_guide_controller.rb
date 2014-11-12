class StyleGuideController < ActionController::Base
  skip_after_filter :intercom_rails_auto_include
  def discussion
    @discussion = Discussion.friendly.find(params[:key])
    @discussion_reader = DiscussionReader.for(discussion: @discussion, user: current_user)
    @group = @discussion.group
  end
end

require 'rails_helper'

describe Users::EmailPreferencesController do
  describe "mark_discussion_as_read" do
    before do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryGirl.build(:discussion, group: @group)
      @event = DiscussionService.start_discussion(@discussion)
    end

    it 'marks the discussion as read at event created_at' do
      get :mark_discussion_as_read, discussion_id: @discussion.id, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token
      DiscussionReader.for(discussion: @discussion, user: @user).unread_comments_count.should == 0
    end
  end

end

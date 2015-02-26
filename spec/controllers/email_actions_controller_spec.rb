require 'rails_helper'

describe EmailActionsController do
  describe "unfollow_discussion" do
    before do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryGirl.build(:discussion, group: @group)
      DiscussionService.create(discussion: @discussion, actor: @user)
      DiscussionReader.for(discussion: @discussion, user: @user).follow!
    end

    it 'unfollows the discussion' do
      DiscussionReader.for(discussion: @discussion, user: @user).following?.should be true
      get :unfollow_discussion, discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token
      DiscussionReader.for(discussion: @discussion, user: @user).following?.should be false
    end
  end

  describe "follow_discussion" do
    before do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryGirl.build(:discussion, group: @group)
      DiscussionService.create(discussion: @discussion, actor: @user)
      DiscussionReader.for(discussion: @discussion, user: @user).unfollow!
    end

    it 'follows the discussion' do
      expect(DiscussionReader.for(discussion: @discussion, user: @user).following?).to eq false 
      get :follow_discussion, discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token
      expect(DiscussionReader.for(discussion: @discussion, user: @user).following?).to eq true
    end
  end

  describe "mark_discussion_as_read" do
    before do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryGirl.build(:discussion, group: @group)
      @event = DiscussionService.create(discussion: @discussion, actor: @user)
    end

    it 'marks the discussion as read at event created_at' do
      get :mark_discussion_as_read, discussion_id: @discussion.id, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token
      expect(DiscussionReader.for(discussion: @discussion, user: @user).unread_comments_count).to eq 0
    end
  end

end

require 'rails_helper'

describe EmailActionsController do
  describe "unfollow_discussion" do
    before do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryGirl.build(:discussion, group: @group)
      DiscussionService.create(discussion: @discussion, actor: @user)
      DiscussionReader.for(discussion: @discussion, user: @user).set_volume! :loud
    end

    it 'stops email notifications for the discussion' do
      expect(DiscussionReader.for(discussion: @discussion, user: @user).volume).to eq 'loud'
      get :unfollow_discussion, discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token
      expect(DiscussionReader.for(discussion: @discussion, user: @user).volume).to eq 'quiet'
    end
  end

  describe "follow_discussion" do
    before do
      @user = FactoryGirl.create(:user)
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryGirl.build(:discussion, group: @group)
      DiscussionService.create(discussion: @discussion, actor: @user)
      DiscussionReader.for(discussion: @discussion, user: @user).set_volume! :normal
    end

    it 'enables emails for the discussion' do
      get :follow_discussion, discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token
      expect(DiscussionReader.for(discussion: @discussion, user: @user).volume).to eq 'loud'
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
      expect(DiscussionReader.for(discussion: @discussion, user: @user).last_read_at).to be_within(1.second).of @event.created_at
    end

    it 'does not error when discussion is not found' do
      get :mark_discussion_as_read, discussion_id: :notathing, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token
      expect(DiscussionReader.for(discussion: @discussion, user: @user).last_read_sequence_id).to eq 0
      expect(response.status).to eq 200
    end
  end

end

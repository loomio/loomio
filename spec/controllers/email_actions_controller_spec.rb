require 'rails_helper'

describe EmailActionsController do
  describe "unfollow_discussion" do
    before do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryBot.build(:discussion, group: @group)
      DiscussionService.create(discussion: @discussion, actor: @user)
      DiscussionReader.for(discussion: @discussion, user: @user).set_volume! :loud
    end

    it 'stops email notifications for the discussion' do
      expect(DiscussionReader.for(discussion: @discussion, user: @user).computed_volume).to eq 'loud'
      get :unfollow_discussion, params: { discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token }
      expect(DiscussionReader.for(discussion: @discussion, user: @user).computed_volume).to eq 'quiet'
    end
  end

  describe "follow_discussion" do
    before do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
      @group.add_member!(@user)

      @discussion = FactoryBot.build(:discussion, group: @group)
      DiscussionService.create(discussion: @discussion, actor: @user)
      DiscussionReader.for(discussion: @discussion, user: @user).set_volume! :normal
    end

    xit 'enables emails for the discussion' do
      get :follow_discussion, params: { discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token }
      expect(DiscussionReader.for(discussion: @discussion, user: @user).computed_volume).to eq 'loud'
    end
  end

  describe "mark_discussion_as_read" do
    before do
      @user = FactoryBot.create(:user)
      @author = FactoryBot.create(:user)
      @group = FactoryBot.create(:group)
      @group.add_member!(@user)
      @group.add_member!(@author)

      @discussion = FactoryBot.build(:discussion, group: @group)
      @event = DiscussionService.create(discussion: @discussion, actor: @author)
    end

    it 'marks the discussion as read at event created_at' do
      get :mark_discussion_as_read, params: { discussion_id: @discussion.id, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token }
      expect(DiscussionReader.for(discussion: @discussion, user: @user).last_read_at).to be_within(1.second).of @event.created_at
    end

    it 'does not error when discussion is not found' do
      get :mark_discussion_as_read, params: { discussion_id: :notathing, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token }
      expect(response.status).to eq 200
    end

    it 'marks a comment as read' do
      @comment_event = CommentService.create(comment: Comment.new(discussion: @discussion, body: "hello"), actor: @author)
      expect(DiscussionReader.for(discussion: @discussion, user: @user).has_read?(@comment_event.sequence_id)).to be false
      get :mark_discussion_as_read, params: { discussion_id: @discussion.id, event_id: @comment_event.id, unsubscribe_token: @user.unsubscribe_token }
      expect(DiscussionReader.for(discussion: @discussion, user: @user).last_read_at).to be_within(1.second).of Time.now
      expect(DiscussionReader.for(discussion: @discussion, user: @user).has_read?(@comment_event.sequence_id)).to be true
    end
  end

  # TODO: this function works but we need to revise the test and/or the mark_as_read method itself, to be based on discussion and sequence ids instead of time
  # describe 'mark_summary_email_as_read' do
  #   it 'marks content as read' do
  #     @user = create(:user)
  #     @voter = create(:user)
  #     @group = create(:group)
  #     @group.add_member!(@user)
  #     @group.add_member!(@voter)
  #     @time_start = 1.hour.ago
  #
  #     @discussion = build(:discussion, group: @group, created_at: @time_start)
  #     DiscussionService.create(discussion: @discussion, actor: @discussion.author)
  #
  #     @poll = build(:poll_proposal, discussion: @discussion, created_at: @time_start)
  #     PollService.create(poll: @poll, actor: @discussion.author)
  #
  #     @stance = build(:stance, poll: @poll, participant: @voter, choice: "agree", created_at: @time_start)
  #     StanceService.create(stance: @stance, actor: @stance.author)
  #
  #     @comment = build(:comment, discussion: @discussion, created_at: @time_start)
  #     CommentService.create(comment: @comment, actor: @discussion.author)
  #
  #     @new_stance = build(:stance, poll: @poll, participant: @voter, choice: "disagree")
  #     StanceService.create(stance: @new_stance, actor: @voter)
  #
  #     reader = DiscussionReader.for(user: @user, discussion: @discussion)
  #     @discussion.reload
  #     expect(@discussion.items_count - reader.read_items_count).to eq 4
  #
  #     get :mark_summary_email_as_read, {
  #       params: {
  #         time_start: @time_start.to_i,
  #         time_finish: 30.minutes.ago.to_i,
  #         unsubscribe_token: @user.unsubscribe_token
  #       },
  #       format: :gif
  #     }
  #
  #     expect(
  #       @discussion.reload.items_count -
  #       reader.reload.read_items_count
  #     ).to eq 1
  #   end
  # end

end

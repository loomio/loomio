require 'rails_helper'

describe Queries::GroupAnalytics do
  let(:group) { create(:group) }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion, group: group) }
  let(:motion) { create(:motion, discussion: discussion) }
  let(:new_discussion_event) { DiscussionService.create(discussion: build(:discussion, group: group), actor: user) }
  let(:new_comment_event)    { CommentService.create(comment: build(:comment, discussion: discussion), actor: user) }
  let(:new_motion_event)     { MotionService.create(motion: build(:motion, discussion: discussion), actor: user) }
  let(:new_vote_event)       { VoteService.create(vote: build(:vote, motion: motion), actor: user) }
  let(:another_user_motion_event) { MotionService.create(motion: build(:motion, discussion: discussion), actor: another_user) }
  let(:yet_another_user_motion_event) { MotionService.create(motion: build(:motion, discussion: discussion), actor: another_user) }
  let(:subject)              { Queries::GroupAnalytics.new(group: group) }
  let(:long_range_subject)   { Queries::GroupAnalytics.new(group: group, since: 4.weeks.ago) }

  before { group.add_member!(user); group.add_member!(another_user) }

  describe 'stats' do
    it 'defaults to 0 if no activity exists' do
      stats = subject.stats
      expect(stats[:motions_created]).to eq 0
      expect(stats[:comments_created]).to eq 0
      expect(stats[:votes_created]).to eq 0
      expect(stats[:active_discussions]).to eq 0
      expect(stats[:active_members]).to eq 0
    end

    it 'counts the number of new motions' do
      new_motion_event
      expect(subject.stats[:motions_created]).to eq 1
      expect(subject.stats[:active_discussions]).to eq 1
      expect(subject.stats[:active_users].count).to eq 1
    end

    it 'does not count motions from before the time period' do
      new_motion_event.update(created_at: 3.weeks.ago)
      expect(subject.stats[:motions_created]).to eq 0
      expect(subject.stats[:active_discussions]).to eq 0
      expect(subject.stats[:active_users].count).to eq 0
    end

    it 'can alter the time period' do
      new_motion_event.update(created_at: 3.weeks.ago)
      expect(long_range_subject.stats[:motions_created]).to eq 1
      expect(long_range_subject.stats[:active_discussions]).to eq 1
      expect(long_range_subject.stats[:active_users].count).to eq 1
    end

    it 'counts the number of new comments' do
      new_comment_event
      expect(subject.stats[:comments_created]).to eq 1
      expect(subject.stats[:active_discussions]).to eq 1
      expect(subject.stats[:active_users].count).to eq 1
    end

    it 'counts the number of new votes' do
      new_vote_event
      expect(subject.stats[:votes_created]).to eq 1
      expect(subject.stats[:active_discussions]).to eq 1
      expect(subject.stats[:active_users].count).to eq 1
    end

    it 'does not double count active discussions' do
      new_comment_event; new_vote_event
      expect(subject.stats[:active_discussions]).to eq 1
    end

    it 'breaks down the activity by user' do
    end

    it 'sorts users by their motion creation activity' do
      new_motion_event; another_user_motion_event; yet_another_user_motion_event
      expect(subject.stats[:active_users][0][:name]).to eq another_user.name
      expect(subject.stats[:active_users][1][:name]).to eq user.name
      expect(subject.stats[:active_users][0][:motions_created]).to eq 2
      expect(subject.stats[:active_users][1][:motions_created]).to eq 1
    end
  end
end
